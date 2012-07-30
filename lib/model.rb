require 'open-uri'

class Page
  include MongoMapper::Document

  key :name, String
  key :content, String
  key :salt, String

  before_create :remove_double_quote, :create_salt, :validate

  def self.find_by_name_and_salt(name, salt)
    where(:name => name, :salt => salt).first
  end

  def link_to_self
    "/#{@salt}/#{URI::encode(@name)}"
  end

  def pretty_link_to_self
    "/#{@salt}/#{@name}"
  end

  def patched_html(add_to_header)
    add_to_header_fragment = Nokogiri::HTML::DocumentFragment.parse add_to_header
    doc = Nokogiri::HTML::Document.parse @content
    page_content = doc.children
    html_tag = doc.css('html').first
    head_tag = doc.css('head').first
    body_tag = doc.css('body').first
    if html_tag.nil?
      html_tag = Nokogiri::XML::Node.new 'html', doc
      html_tag.parent = doc
    end
    if head_tag.nil?
      head_tag = Nokogiri::XML::Node.new 'head', doc
      head_tag.parent = html_tag
    end
    if body_tag.nil?
      body_tag = Nokogiri::XML::Node.new 'body', doc
      body_tag.parent = html_tag
      body_tag.children = page_content
    end

    head_tag.add_child add_to_header_fragment

    doc.to_html
  end

  private

  def remove_double_quote
    @name = @name.gsub('"', "'")
  end

  def create_salt
    @salt = '%.3i' % (rand * 999)
  end

  def validate
    raise "validation error" if Page.find_by_name_and_salt(@name, @salt)
  end
end

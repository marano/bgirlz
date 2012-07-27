class Page
  include MongoMapper::Document

  key :name, String
  key :content, String
  key :salt, String

  before_create :create_salt

  def link_to_self
    "/#{@salt}/#{@name}"
  end

  def patched_html
    doc = Nokogiri::HTML::Document.parse @content
    head_tag = doc.css('head').first
    if head_tag.nil?
      head_tag = Nokogiri::XML::Node.new 'head', doc
      doc.css('html').first.add_child head_tag
    end

    jquery_script_tag = Nokogiri::XML::Node.new 'script', doc
    jquery_script_tag.set_attribute 'type', 'text/javascript'
    jquery_script_tag.set_attribute 'src', '//ajax.googleapis.com/ajax/libs/jquery/1.7.0/jquery.min.js'
    head_tag.add_child jquery_script_tag
    patch_script_tag = Nokogiri::XML::Node.new 'script', doc
    patch_script_tag.set_attribute 'type', 'text/javascript'
    patch_script_tag.set_attribute 'src', '/patch.js'
    head_tag.add_child patch_script_tag

    doc.to_html
  end

  private

  def create_salt
    @salt = '%.3i' % (rand * 999)
  end
end

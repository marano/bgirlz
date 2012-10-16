require 'open-uri'

class Page
  include MongoMapper::Document

  key :name, String
  key :middle_initial, String
  key :last_name, String
  key :event, String
  key :content, String
  key :salt, String
  key :enable_comments, Boolean
  key :favorite, Boolean
  key :original_link, String
  timestamps!

  before_create :create_salt_before_create, :validate
  after_create :create_link_after_create!
  before_update :create_salt_before_update, :create_link_before_update!
  after_destroy :destroy_links

  def self.publish!(name, middle_initial, last_name, event, enable_comments, content)
    return if invalid_page?(name, content)

    page_data = {name: name, middle_initial: middle_initial, last_name: last_name, event: event, :content => content, :enable_comments => enable_comments == 'on'}

    if Page.new_url_format?(name, middle_initial, last_name, event)
      existent_page = Page.find_by_full_name_and_event(name, middle_initial, last_name, event)
      if existent_page.nil?
        return Page.create! page_data
      else
        existent_page.update_attributes! page_data
        return existent_page
      end
    else
      return Page.create! page_data
    end
  end

  def self.invalid_page?(name, content)
    name.blank? || content.blank?
  end

  def self.new_url_format?(name, middle_initial, last_name, event)
    !name.blank? && !middle_initial.blank? && !last_name.blank? && !event.blank?
  end

  def new_url_format?
    Page.new_url_format?(@name, @middle_initial, @last_name, @event)
  end

  def self.find_by_name_and_salt(name, salt)
    where(:name => name, :salt => salt).first
  end

  def self.find_by_full_name_and_event(name, middle_initial, last_name, event)
    where(name: name, middle_initial: middle_initial, last_name: last_name, event: event).first
  end

  def self.random_featured_pages_links
    Page.all(:favorite => true).randomize.slice(0..10).map(&:original_link_page_link)
  end

  def self.previous_events
    Page.all.select { |p| !p.event.blank? }.map(&:event).uniq
  end

  def formatted_created_at
    created_at.strftime("%m/%d/%Y") unless created_at.nil?
  end

  def full_name
    if @middle_initial.blank?
      batman = @name
    else
      batman = "#{@name} #{@middle_initial}"
    end
    if @last_name.blank?
      return batman
    else
      return "#{batman} #{@last_name}"
    end
  end

  def link_to_self(request)
    "http://#{request.host_with_port}#{relative_link_to_self}"
  end

  def original_link_to_self(request)
    "http://#{request.host_with_port}#{@original_link}"
  end

  def pretty_link_to_self(request)
    "http://#{request.host_with_port}#{relative_pretty_link_to_self}"
  end

  def relative_link_to_self
    if new_url_format?
      "/#{URI::encode(@event)}/#{URI::encode(@name)}_#{URI::encode(@middle_initial)}_#{URI::encode(@last_name)}"
    else
      "/#{@salt}/#{URI::encode(@name)}"
    end
  end

  def relative_link_to_content
    "#{relative_link_to_self}/content"
  end

  def relative_link_to_featured
    "#{relative_link_to_self}/featured"
  end

  def relative_link_to_change_event
    "#{relative_link_to_self}/change_event"
  end

  def relative_link_to_update_name
    "#{relative_link_to_self}/update_name"
  end

  def relative_link_to_favorite
    "#{relative_link_to_self}/favorite"
  end

  def relative_link_to_unfavorite
    "#{relative_link_to_self}/unfavorite"
  end

  def relative_pretty_link_to_self
    if new_url_format?
      "/#{@event}/#{@name}_#{@middle_initial}_#{@last_name}"
    else
      "/#{@salt}/#{@name}"
    end
  end

  def relative_panel_path
    if new_url_format?
      "/#{URI::encode(@event)}/#{URI::encode(@name)}_#{URI::encode(@middle_initial)}_#{URI::encode(@last_name)}/panel"
    else
      "/#{@salt}/#{URI::encode(@name)}/panel"
    end
  end

  def favorite!
    @favorite = true
    save!
  end

  def unfavorite!
    @favorite = false
    save!
  end

  def patched_html(add_to_header, add_to_body)
    add_to_header_fragment = Nokogiri::HTML::DocumentFragment.parse add_to_header
    add_to_body_fragment = Nokogiri::HTML::DocumentFragment.parse add_to_body
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
    body_tag.add_child add_to_body_fragment

    doc.to_html
  end

  def have_image?
    @content.include? '<img'
  end

  def have_video?
    @content.include? 'http://www.youtube.com/embed/'
  end

  def have_music?
    @content.include?('http://www.miniclip.com/games/soccer-stars/en/webgame.php') || @content.include?('soundcloud.com/player')
  end

  def have_stylesheet?
    @content.include? '<style>'
  end

  def have_html_errors?
    !Nokogiri::HTML(@content).errors.empty?
  end

  def original_link_page_link
    PageLink.find_by_link(@original_link)
  end

  private

  def create_salt_before_create
    unless new_url_format?
      generate_salt
    end
  end

  def create_salt_before_update
    unless new_url_format? || @salt
      generate_salt
    end
  end

  def generate_salt
    @salt = '%.3i' % (rand * 999)
  end

  def validate
    if new_url_format?
      raise "validation error" if Page.find_by_full_name_and_event(@name, @middle_initial, @last_name, @event)
    else
      raise "validation error" if Page.find_by_name_and_salt(@name, @salt)
    end
  end

  def create_link!
    PageLink.create!(:page_id => _id.to_s, :link => relative_link_to_self).link
  end

  def create_link_after_create!
    @original_link = create_link!
    save!
  end

  def create_link_before_update!
    unless links.map(&:link).include?(relative_link_to_self)
      create_link!
    end
  end

  def links
    PageLink.all(:page_id => _id.to_s)
  end

  def destroy_links
    links.each { |link| link.destroy }
  end
end

class PageLink
  include MongoMapper::Document

  key :link, String, :required => true, :unique => true
  key :page_id, String, :required => true
  timestamps!

  def url(request)
    "http://#{request.host_with_port}#{@link}"
  end

  def featured
    "#{@link}/featured"
  end

  def to_json_hash(request)
    { self: url(request), featured: featured }
  end
end

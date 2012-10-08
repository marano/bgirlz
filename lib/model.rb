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
  timestamps!

  before_create :create_salt, :validate

  def self.publish!(name, middle_initial, last_name, event, enable_comments, content)
    return if invalid_page?(name, content)

    page_data = {name: name, middle_initial: middle_initial, last_name: last_name, event: event, :content => content, :enable_comments => enable_comments == 'on'}

    if new_url_format?(name, middle_initial, last_name, event)
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

  def self.find_by_name_and_salt(name, salt)
    where(:name => name, :salt => salt).first
  end

  def self.find_by_full_name_and_event(name, middle_initial, last_name, event)
    where(name: name, middle_initial: middle_initial, last_name: last_name, event: event).first
  end

  def self.featured_pages_links_list
    Page.where(:favorite => true).map(&:relative_link_to_featured).randomize.slice(0..10)
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

  def pretty_link_to_self(request)
    "http://#{request.host_with_port}#{relative_pretty_link_to_self}"
  end

  def relative_link_to_self
    if @salt
      "/#{@salt}/#{URI::encode(@name)}"
    else
      "/#{URI::encode(@event)}/#{URI::encode(@name)}_#{URI::encode(@middle_initial)}_#{URI::encode(@last_name)}"
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
    if @salt
      "/#{@salt}/#{@name}"
    else
      "/#{@event}/#{@name}_#{@middle_initial}_#{@last_name}"
    end
  end

  def relative_panel_path
    if @salt
      "/#{@salt}/#{URI::encode(@name)}/panel"
    else
      "/#{URI::encode(@event)}/#{URI::encode(@name)}_#{URI::encode(@middle_initial)}_#{URI::encode(@last_name)}/panel"
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

  private

  def create_salt
    if @middle_initial.blank? ||  @last_name.blank? || @event.blank?
      @salt = '%.3i' % (rand * 999)
    end
  end

  def validate
    if @salt
      raise "validation error" if Page.find_by_name_and_salt(@name, @salt)
    else
      raise "validation error" if Page.find_by_full_name_and_event(@name, @middle_initial, @last_name, @event)
    end
  end
end

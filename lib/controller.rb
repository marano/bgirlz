require 'net/http'
require 'openssl'

class Controller < Sinatra::Base

  set :views, 'views'
  set :public_folder, 'public'
  use Rack::MethodOverride

  def previous_events
    Page.all.select { |p| !p.event.blank? }.map(&:event).uniq
  end

  get '/previous_events' do
    previous_events.to_json
  end

  get '/featured_pages' do
    Page.random_page_links_list.to_json
  end

  get '/' do
    @name = params[:name]
    @middle_initial = params[:middle_initial]
    @last_name = params[:last_name]
    @event = params[:event]
    haml :home
  end

  post '/upload' do
    @name = params[:name]
    @middle_initial = params[:middle_initial]
    @last_name = params[:last_name]
    @event = params[:event]
    @link = params[:link]
    @page = params[:page]
    @enable_comments = params[:enable_comments]
    @html = params[:html]

    if @name.blank? || (@link.blank? && @page.blank? && @html.blank?)
      redirect "/?#{@name.blank? ? '' : '&name=' + @name }#{@middle_initial.blank? ? '' : '&middle_initial=' + @middle_initial }#{@last_name.blank? ? '' : '&last_name=' + @last_name }#{@event.blank? ? '' : '&event=' + @event }"
      return
    end

    if !@link.blank?
      content = content_from_link(@link)
    elsif !@page.blank?
      content = File.read @page[:tempfile].path
    else
      content = @html
    end

    page_data = {name: @name, middle_initial: @middle_initial, last_name: @last_name, event: @event, :content => content, :enable_comments => @enable_comments == 'on'}

    if !@name.blank? && !@middle_initial.blank? && !@last_name.blank? && !@event.blank?
      exitstent_page = Page.find_by_full_name_and_event(@name, @middle_initial, @last_name, @event)
      if exitstent_page.nil?
        uploaded_page = Page.create! page_data
      else
        exitstent_page.update_attributes! page_data
        uploaded_page = exitstent_page
      end
    else
      uploaded_page = Page.create! page_data
    end

    redirect uploaded_page.link_to_self(request) + '?first_time=true'
  end

  def content_from_link(link)
    uri = URI.parse(link)
    http = Net::HTTP.new(uri.host, uri.port) 

    if link =~ /https:/
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)

    if response.code == '301'
      new_location = response.header['Location']
      return content_from_link(new_location)
    else
      return response.body
    end
  end

  get '/favicon.ico' do
  end

  get '/list' do
    @pages = Page.all
    @previous_events = previous_events
    haml :list
  end

  def resolve_page_from_path
    if params[:first] =~ /\A[0-9]{3}\z/
      salt = params[:first]
      name = params[:last]
      return Page.find_by_name_and_salt(name, salt)
    else
      event = params[:first]
      name_parts = params[:last].split('_')
      name = name_parts[0]
      middle_initial = name_parts[1]
      last_name = name_parts[2]
      return Page.find_by_full_name_and_event(name, middle_initial, last_name, event)
    end
  end

  get '/:first/:last' do
    @first_time = params[:first_time]
    @page = resolve_page_from_path
    if @page.nil?
      status 404
      "404 Not found"
    else
      add_to_header = erb :_page_header, :layout => false
      add_to_body = erb :_comments, :layout => false
      @page.patched_html add_to_header, add_to_body
    end
  end

  get '/:first/:last/content' do
    @page = resolve_page_from_path
    if @page.nil?
      status 404
      "404 Not found"
    else
      add_to_header = erb :_page_header, :layout => false
      add_to_body = erb :_comments, :layout => false
      @page.content
    end
  end

  get '/:first/:last/featured' do
    @page = resolve_page_from_path
    if @page.nil?
      status 404
      "404 Not found"
    else
      haml :_featured, :layout => false
    end
  end

  put '/:first/:last/favorite' do
    @page = resolve_page_from_path
    if @page.nil?
      status 404
      "404 Not found"
    else
      @page.favorite!
      status 200
    end
  end

  put '/:first/:last/unfavorite' do
    @page = resolve_page_from_path
    if @page.nil?
      status 404
      "404 Not found"
    else
      @page.unfavorite!
      status 200
    end
  end

  delete '/:first/:last' do
    @page = resolve_page_from_path
    if @page.nil?
      status 404
      "404 Not found"
    else
      @page.delete
    end
    redirect '/list'
  end

  get '/:first/:last/panel' do
    @page = resolve_page_from_path
    if @page.nil?
      status 404
      "404 Not found"
    else
      erb :_page_info_panel, :layout => false
    end
  end
end

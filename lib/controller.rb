require 'net/http'
require 'openssl'

class Controller < Sinatra::Base

  set :views, 'views'
  set :public_folder, 'public'
  use Rack::MethodOverride

  get '/previous_events' do
    Page.all.map { |p| p.event }.compact.to_json
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
    new_page = Page.create!(:name => @name, :middle_initial => @middle_initial, :last_name => @last_name, :event => @event, :content => content, :enable_comments => @enable_comments == 'on')
    redirect new_page.link_to_self(request) + '?first_time=true'
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
    haml :list
  end

  get '/:salt/:name' do
    @first_time = params[:first_time]
    @page = Page.find_by_name_and_salt(params[:name], params[:salt])
    show_page(@page)
  end

  get '/:event/:name/:middle_initial/:last_name' do
    @first_time = params[:first_time]
    name = params[:name]
    middle_initial = params[:middle_initial]
    last_name = params[:last_name]
    event = params[:event]
    @page = Page.find_by_full_name_and_event(name, middle_initial, last_name, event)
    show_page(@page)
  end

  def show_page(page)
    if page.nil?
      status 404
      "404 Not found"
    else
      add_to_header = erb :_page_header, :layout => false
      add_to_body = erb :_comments, :layout => false
      page.patched_html add_to_header, add_to_body
    end
  end

  delete '/:salt/:name' do
    @page = Page.find_by_name_and_salt(params[:name], params[:salt])
    if @page.nil?
      status 404
      "404 Not found"
    else
      @page.delete
    end
    redirect '/list'
  end

  delete '/:event/:name/:middle_initial/:last_name' do
    name = params[:name]
    middle_initial = params[:middle_initial]
    last_name = params[:last_name]
    event = params[:event]
    @page = Page.find_by_full_name_and_event(name, middle_initial, last_name, event)
    if @page.nil?
      status 404
      "404 Not found"
    else
      @page.delete
    end
    redirect '/list'
  end

  get '/:salt/:name/panel' do
    @page = Page.find_by_name_and_salt(params[:name], params[:salt])
    if @page.nil?
      status 404
      "404 Not found"
    else
      erb :_page_info_panel, :layout => false
    end
  end

  get '/:event/:name/:middle_initial/:last_name/panel' do
    name = params[:name]
    middle_initial = params[:middle_initial]
    last_name = params[:last_name]
    event = params[:event]
    @page = Page.find_by_full_name_and_event(name, middle_initial, last_name, event)
    if @page.nil?
      status 404
      "404 Not found"
    else
      erb :_page_info_panel, :layout => false
    end
  end

end

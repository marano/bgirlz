require 'net/http'
require 'openssl'
require_relative 'modules'

class Controller < Sinatra::Base

  set :views, 'views'
  set :public_folder, 'public'

  set :protection, :except => :frame_options
  use Rack::MethodOverride
  include Rack::Utils

  include LinkOpener

  get '/previous_events' do
    Page.previous_events.to_json
  end

  get '/featured_pages' do
    Page.random_featured_pages_links.map { |link| link.to_json_hash(request) }.to_json
  end

  get '/' do
    @name = params[:name]
    @middle_initial = params[:middle_initial]
    @last_name = params[:last_name]
    @event = params[:event]
    haml :home
  end

  post '/upload' do
    name = params[:name]
    middle_initial = params[:middle_initial]
    last_name = params[:last_name]
    event = params[:event]
    enable_comments = params[:enable_comments]
    content = content_from(params)

    uploaded_page = Page.publish!(name, middle_initial, last_name, event, enable_comments, content)

    if uploaded_page.nil?
      redirect_home_with_input(name, middle_initial, last_name, event)
    else
      redirect uploaded_page.link_to_self(request) + '?first_time=true'
    end
  end

  get '/favicon.ico' do
  end

  get '/list' do
    @events = Event.all
    haml :list
  end

  get '/featured_pages/embedded' do
    @color = params[:color]
    @height = params[:height] || '600px'
    haml :featured_pages_embedded
  end

  not_found do
    "404 Not found"
  end

  put '/event/:current_name' do
    @event = Event.new(params[:current_name])
    @event.update_name!(params[:name])
    status 200
  end

  get '/event/:name/featured_pages' do
    @event = Event.new(params[:name])
    haml :event_featured_pages
  end

  get '/event/:name/featured_pages/links' do
    Event.new(params[:name]).pages.map(&:original_link_page_link).map { |link| link.to_json_hash(request) }.to_json
  end

  get '/*/content' do
    @page = resolve_page_from_path
    add_to_header = erb :_page_header, :layout => false
    add_to_body = erb :_comments, :layout => false
    @page.content
  end

  get '/*/featured' do
    @page = resolve_page_from_path
    haml :_featured, :layout => false
  end

  put '/*/change_event' do
    page = resolve_page_from_path
    page.event = params[:event]
    page.save!
    status 200
  end

  put '/*/update_name' do
    page = resolve_page_from_path
    page.name = params[:name]
    page.middle_initial = params[:middle_initial]
    page.last_name = params[:last_name]
    page.save!
    status 200
  end

  put '/*/favorite' do
    resolve_page_from_path.favorite!
    status 200
  end

  put '/*/unfavorite' do
    resolve_page_from_path.unfavorite!
    status 200
  end

  delete '/*' do
    resolve_page_from_path.destroy
    redirect '/list'
  end

  get '/*/panel' do
    @page = resolve_page_from_path
    erb :_page_info_panel, :layout => false
  end

  get '/*' do
    @first_time = params[:first_time]
    @page = resolve_page_from_path
    add_to_header = erb :_page_header, :layout => false
    add_to_body = erb :_comments, :layout => false
    @page.patched_html add_to_header, add_to_body
  end

  private

  def redirect_home_with_input(name, middle_initial, last_name, event)
    redirect "/?#{name.blank? ? '' : '&name=' + name }#{middle_initial.blank? ? '' : '&middle_initial=' + middle_initial }#{last_name.blank? ? '' : '&last_name=' + last_name }#{event.blank? ? '' : '&event=' + event }"
  end

  def content_from(params)
    link = params[:link]
    page = params[:page]
    html = params[:html]
    return content_from_link(link) unless link.blank?
    return File.read(page[:tempfile].path) unless page.blank?
    return html unless html.blank?
  end

  def resolve_page_from_path
    link = PageLink.by_link "/#{params[:splat].first}"
    unless link.nil?
      page = link.page
    end
    if page.nil?
      raise Sinatra::NotFound
    else
      return page
    end
  end
end

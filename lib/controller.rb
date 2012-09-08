class Controller < Sinatra::Base

  set :views, 'views'
  use Rack::MethodOverride

  get '/' do
    @name = params[:name]
    erb :home
  end

  post '/upload' do
    @name = params[:name]
    @middle_initial = params[:middle_initial]
    @last_name = params[:last_name]
    @page = params[:page]
    @enable_comments = params[:enable_comments]
    @html = params[:html]
    if @name.blank? || (@page.nil? && @html.blank?)
      redirect "/#{@name.blank? ? '' : '?name=' + @name }"
      return
    end
    if @page
      content = File.read @page[:tempfile].path
    else
      content = @html
    end
    new_page = Page.create!(:name => @name, :middle_initial => @middle_initial, :last_name => @last_name, :content => content, :enable_comments => @enable_comments == 'on')
    redirect new_page.link_to_self(request) + '?first_time=true'
  end

  get '/favicon.ico' do
  end

  get '/list' do
    @pages = Page.all
    erb :list
  end

  get '/:salt/:name' do
    @first_time = params[:first_time]
    @page = Page.find_by_name_and_salt(params[:name], params[:salt])
    show_page(@page)
  end

  get '/:name/:middle_initial/:last_name' do
    @first_time = params[:first_time]
    name = params[:name]
    middle_initial = params[:middle_initial]
    last_name = params[:last_name]
    @page = Page.find_by_full_name(name, middle_initial, last_name)
    show_page(@page)
  end

  def show_page(page)
    if page.nil?
      status 404
      "404 Not found"
    else
      add_to_header = erb :_page_header
      add_to_body = erb :_comments
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

  get '/:salt/:name/panel' do
    @page = Page.find_by_name_and_salt(params[:name], params[:salt])
    if @page.nil?
      status 404
      "404 Not found"
    else
      erb :_page_info_panel
    end
  end

end

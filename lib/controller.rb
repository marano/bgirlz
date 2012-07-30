get '/' do
  @name = params[:name]
  erb :home
end

post '/upload' do
  @name = params[:name]
  @page = params[:page]
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
  new_page = Page.create!(:name => @name, :content => content)
  redirect new_page.link_to_self + '?first_time=true'
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
  if @page.nil?
    status 404
    "404 Not found"
  else
    @page_name = @page.name
    @page_salt = @page.salt
    add_to_header = erb :_page_header
    @page.patched_html add_to_header
  end
end

get '/:salt/:name/panel' do
  @page = Page.find_by_name_and_salt(params[:name], params[:salt])
  if @page.nil?
    status 404
    "404 Not found"
  else
    @page_link = "http://bgirlz.heroku.com#{@page.link_to_self}"
    @pretty_page_link = "http://bgirlz.heroku.com#{@page.pretty_link_to_self}"
    erb :_page_info_panel
  end
end

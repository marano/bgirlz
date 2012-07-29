get '/' do
  @name = params[:name]
  erb :home
end

post '/upload' do
  name = params[:name]
  page = params[:page]
  if name.blank? || page.nil?
    redirect "/?name=#{name}"
    return
  end
  content = File.read page[:tempfile].path
  page = Page.create!(:name => name, :content => content)
  redirect page.link_to_self
end

get '/favicon.ico' do
end

get '/list' do
  @pages = Page.all
  erb :list
end

get '/:salt/:name' do
  results = Page.where(:name => params[:name], :salt => params[:salt])
  if results.empty?
    status 404
    "404 Not found"
  else
    results.first.patched_html
  end
end

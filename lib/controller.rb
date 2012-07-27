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
  Page.create!(:name => name, :content => content)
  redirect "/#{name}"
end

get '/favicon.ico' do
end

get '/:name' do
  Page.where(:name => params[:name]).first.content
end

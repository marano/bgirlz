get '/' do
  erb :home
end

post '/upload' do
  name = params[:name]
  content = File.read params[:page][:tempfile].path
  Page.create!(:name => name, :content => content)
  redirect "/#{name}"
end

get '/favicon.ico' do
end

get '/:name' do
  Page.where(:name => params[:name]).first.content
end

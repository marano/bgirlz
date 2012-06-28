get '/' do
  erb :home
end

post '/upload' do
  name = params[:name]
  FileUtils.cp(params[:page][:tempfile].path, "#{File.dirname(__FILE__)}/../pages/#{name}.html")
  redirect "/#{name}"
end

get '/:name' do
  File.read("#{File.dirname(__FILE__)}/../pages/#{params[:name]}.html")
end

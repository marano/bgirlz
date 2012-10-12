path = File.expand_path(File.join(File.dirname(__FILE__)))
$LOAD_PATH << path

require 'bundler'
envs = [:default]
envs << ENV['RACK_ENV']
envs << :development if ENV['RACK_ENV'] != 'production'
Bundler.require *(envs.map(&:to_sym))


Dir['lib/**/*.rb'].each { |file| require file }

if ENV['RACK_ENV'] == 'test'
  mongo_url = 'mongodb://localhost:27017/bgirlz_test'
else
  mongo_url = ENV['MONGOHQ_URL'] || 'mongodb://localhost:27017/bgirlz'
end

MongoMapper.config = { 'girlz' => { 'uri' => mongo_url } }
MongoMapper.connect('girlz')

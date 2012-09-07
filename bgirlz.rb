path = File.expand_path(File.join(File.dirname(__FILE__)))
$LOAD_PATH << path

require 'bundler'
envs = [:default]
envs << :development if ENV['RACK_ENV'] != 'production'
envs << :test if ENV['RACK_ENV'] == 'test'
Bundler.require *envs


Dir['lib/**/*.rb'].each { |file| require file }

if ENV['RACK_ENV'] == 'test'
  mongo_url = 'mongodb://localhost:27017/bgirlz_test'
else
  mongo_url = ENV['MONGOHQ_URL'] || 'mongodb://localhost:27017/bgirlz'
end

MongoMapper.config = { 'girlz' => { 'uri' => mongo_url } }
MongoMapper.connect('girlz')

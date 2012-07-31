path = File.expand_path(File.join(File.dirname(__FILE__)))
$LOAD_PATH << path

require 'bundler'
envs = [:default]
envs << :development if ENV['RACK_ENV'] != 'production'
Bundler.require *envs


Dir['lib/**/*.rb'].each { |file| require file }

mongo_url = ENV['MONGOHQ_URL'] || 'mongodb://localhost:27017/bgirlz'
MongoMapper.config = { 'girlz' => { 'uri' => mongo_url } }
MongoMapper.connect('girlz')

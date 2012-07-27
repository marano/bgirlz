path = File.expand_path(File.join(File.dirname(__FILE__)))
$LOAD_PATH << path

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

set :app_file, __FILE__

Dir['lib/**/*.rb'].each { |file| require file }

mongo_url = ENV['MONGOHQ_URL'] || 'mongodb://localhost:27017/bgirlz'
MongoMapper.config = { 'girlz' => { 'uri' => mongo_url } }
MongoMapper.connect('girlz')

path = File.expand_path(File.join(File.dirname(__FILE__)))
$LOAD_PATH << path

require 'rubygems'
require 'bundler'
Bundler.require :default

set :app_file, __FILE__

Dir['lib/**/*.rb'].each { |file| require file }

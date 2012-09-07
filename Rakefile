path = File.expand_path(File.join(File.dirname(__FILE__)))
$LOAD_PATH << path
require 'rake'

task :default => :test

task :console do
  require 'bgirlz'
  Pry.start
end

task :server do
  sh 'rackup'
end

task :test do
  sh 'rspec spec.rb'
end

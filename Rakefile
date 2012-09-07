require 'rake'

task :default => :test

task :console do
  require_relative 'bgirlz'
  Pry.start
end

task :server do
  sh 'rackup'
end

task :test do
  sh 'rspec spec.rb'
end

require 'rake'

task :default => :test

task :console do
  ENV['RACK_ENV'] = 'development'
  require_relative 'bgirlz'
  Pry.start
end

task :server do
  sh 'rackup'
end

task :test do
  sh 'rspec spec.rb'
end

task :deploy do
  sh 'git remote add heroku git@heroku.com:bgirlz.git'
  sh 'git push heroku +master:master'
end

require 'rake'

task :default => :test

task :console do
  ENV['RACK_ENV'] = 'development'
  require_relative 'bgirlz'
  Pry.start
end

task :ci => [:test, :trigger_deploy]

task :server do
  sh 'rackup'
end

task :test do
  sh 'rspec spec.rb'
end

task :trigger_deploy do
  sh 'wget -O /dev/null http://fourbongo.com:8080/job/bgirlz-deploy/build'
end

task :deploy do
  sh 'git push heroku'
end

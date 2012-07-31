require 'rake'

task :default => :test

task :server do
  sh 'rackup'
end

task :test do
  sh 'rspec spec/app_spec.rb'
end

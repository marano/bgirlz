require 'rake'

task :default => :test

task :console do
  ENV['RACK_ENV'] ||= 'development'
  require_relative 'bgirlz'
  Pry.start
end

task :ci => [:test, 'deploy:stage']

task :server do
  sh 'rackup'
end

task :test do
  sh 'rspec spec.rb'
end

namespace :deploy do
  task :prod do
    sh 'wget -O /dev/null http://fourbongo.com:8080/job/bgirlz-deploy/build --post-data ""'
  end
  task :stage do
    sh 'wget -O /dev/null http://fourbongo.com:8080/job/bgirlz-deploy-stage/build --post-data ""'
  end
end

task :last_travis_success_revision do
  require 'json'
  require_relative 'lib/modules'
  include LinkOpener
  builds = JSON.parse(content_from_link('https://travis-ci.org/marano/bgirlz/builds.json'))
  puts builds.select { |build| build['result'] == 0 }.first['commit']
end

namespace :migrate do
  task :create_events do
    ENV['RACK_ENV'] ||= 'development'
    require_relative 'bgirlz'
    Page.all.sort_by { |page| page.created_at || Time.parse('14-12-1901') }.map(&:event).select { |event| !event.blank? }.uniq.each do |event_name|
      Event.create(:name => event_name)
    end
  end
end

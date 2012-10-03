ENV['RACK_ENV'] = 'test'

require 'tempfile'

require_relative 'bgirlz'

require 'capybara/rspec'
require 'capybara/dsl'

RSpec.configure do |c|
  c.include Capybara::DSL
  c.before do
    Page.destroy_all
    Capybara.reset_sessions!
  end
end

Capybara.app = Controller

if ENV['headless'] =~ /false/
  Capybara.current_driver = :selenium
  Capybara.javascript_driver = :selenium
else
  Headless.new.start
  Capybara.current_driver = :webkit
  Capybara.javascript_driver = :webkit
end

include LinkOpener

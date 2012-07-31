ENV['RACK_ENV'] = 'test'

require 'tempfile'

require_relative '../bgirlz'

require 'capybara/rspec'
require 'capybara/dsl'


RSpec.configure do |c|
  c.include Capybara::DSL
  c.before do
    Capybara.reset_sessions!
  end
end

Capybara.app = Controller

describe 'Black Girls Code Website Publisher' do
  it 'should allow me to update my website' do
    visit '/'
    fill_in 'name', :with => 'Joana'
    fill_in 'html', :with => 'oi!'
    click_button 'Publish my website'
    page.text.should == 'oi!'
  end
end

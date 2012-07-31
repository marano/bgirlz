ENV['RACK_ENV'] = 'test'

require 'bundler'
Bundler.require :test

require 'capybara/rspec'
require 'capybara/dsl'

require_relative '../bgirlz'

RSpec.configure do |c|
  c.include Capybara::DSL
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

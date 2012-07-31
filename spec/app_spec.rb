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

Capybara.current_driver = :selenium

describe 'Black Girls Code Website Publisher' do
  it 'should allow me to publish my website' do
    visit '/'
    fill_in 'name', :with => 'Joana'
    fill_in 'html', :with => 'oi!'
    click_button 'Publish my website'
    page.text.should == 'oi!'
  end

  it 'should allow me to publish my website using a file' do
    visit '/'
    fill_in 'name', :with => 'Joana'
    page_file = Tempfile.new('mypage.html')
    page_file.write 'oi!'
    page_file.flush
    attach_file('page', page_file.path)
    click_button 'Publish my website'
    page.text.should == 'oi!'
  end
end

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

Capybara.current_driver = :selenium

describe 'Black Girls Code Website Publisher', :js => true do
  it 'should allow me to publish my website' do
    visit '/'
    fill_in 'name', :with => 'Joana'
    fill_in 'html', :with => 'oi!'
    click_button 'Publish my website'
    page.text.should == 'oi!'
    visit Page.first.relative_link_to_self
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
    visit Page.first.relative_link_to_self
    page.text.should == 'oi!'
  end

  it 'should display my page at list page' do
    visit '/'
    fill_in 'name', :with => 'Joana'
    fill_in 'html', :with => 'oi!'
    click_button 'Publish my website'
    visit '/list'
    page.should have_content('Joana')
    page.should have_link(Page.first.relative_link_to_self)
  end

  it 'should be able to delete page from list page' do
    visit '/'
    fill_in 'name', :with => 'Joana'
    fill_in 'html', :with => 'oi!'
    click_button 'Publish my website'
    visit '/list'
    @page = Page.first
    page.should have_content(@page.name)
    page.should have_link(@page.relative_link_to_self)
    page.evaluate_script('window.confirm = function() { return true; }')
    page.find('.delete').click
    page.should_not have_content(@page.name)
    page.should_not have_link(@page.relative_link_to_self)
    visit @page.relative_link_to_self
    page.should have_content('404 Not found')
  end
end

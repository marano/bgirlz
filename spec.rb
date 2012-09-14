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

def upload_page(params)
  visit '/'
  fill_in 'name', :with => params[:name]
  fill_in 'middle_initial', :with => params[:middle_initial]
  fill_in 'last_name', :with => params[:last_name]
  fill_in 'event', :with => params[:event]
  if params[:html]
    page.click_link 'HTML'
    fill_in 'html', :with => params[:html]
  end
  if params[:link]
    page.click_link 'Link'
    fill_in 'link', :with => params[:link]
  end
  if params[:page]
    page.click_link 'File'
    attach_file('page', params[:page])
  end
  click_button 'Publish my website'
  Page.where(:name => params[:name]).first
end

def assert_upload_is_ok(uploaded_page)
  host = Capybara.current_session.driver.rack_server.host
  port = Capybara.current_session.driver.rack_server.port
  link = "http://#{host}:#{port}#{uploaded_page.relative_link_to_self}"
  pretty_link = "http://#{host}:#{port}#{uploaded_page.relative_pretty_link_to_self}"
  page.should have_content pretty_link
  page.should have_link link

  page.should have_content uploaded_page.content
  page.find('#info_panel').should be_visible
  page.click_link 'close'
  page.find('#info_panel').should_not be_visible
  visit uploaded_page.relative_link_to_self
  page.should have_content uploaded_page.content
  page.should_not have_css('#info_panel')
end

describe 'Black Girls Code Website Publisher', :js => true do

  it 'should allow me to publish my website and show me info bar' do
    @page = upload_page(:name => 'Cecilia',
                        :html => 'Eaí Bob!')

    assert_upload_is_ok(@page)
  end

  it 'should allow me to publish my website using a file' do
    page_file = Tempfile.new('mypage.html')
    page_file.write 'oi!'
    page_file.flush

    @page = upload_page(:name => 'Cecilia',
                        :page => page_file.path)

    assert_upload_is_ok(@page)
  end

  it 'should be able to import website from link' do
    @page = upload_page(:name => 'Joana',
                        :html => 'oi!')

    host = Capybara.current_session.driver.rack_server.host
    port = Capybara.current_session.driver.rack_server.port
    link = "http://#{host}:#{port}#{Page.first.relative_pretty_link_to_self}/content"

    @page = upload_page(:name => 'Augusta',
                        :link => link)

    assert_upload_is_ok(@page)
  end

  it 'should display my page at list page' do
    @page = upload_page(:name => 'Joana',
                        :html => 'oi!')
    visit '/list'
    page.find('.date').text.should == @page.created_at.strftime("%m/%d/%Y")
    page.find('.name').text.should == @page.name
    page.should have_link(@page.relative_link_to_self)
  end

  it 'should be able to delete page from list page' do
    @page = upload_page(:name => 'Joana',
                        :html => 'oi!')
    visit '/list'
    page.should have_content(@page.name)
    page.should have_link(@page.relative_link_to_self)
    page.evaluate_script('window.confirm = function() { return true; }')
    page.find('#enable-delete .icon-trash').click
    page.find('.delete .icon-trash').click
    page.should_not have_content(@page.name)
    page.should_not have_link(@page.relative_link_to_self)
    visit @page.relative_link_to_self
    page.should have_content('404 Not found')
  end

  it 'should be able to delete page with new url format from list page' do
    @page = upload_page(:name => 'Joana',
                        :middle_initial => 'Silva',
                        :last_name => 'Sauro',
                        :event => 'Event1',
                        :html => 'oi!')
    visit '/list'
    page.evaluate_script('window.confirm = function() { return true; }')
    page.find('#enable-delete .icon-trash').click
    page.find('.delete .icon-trash').click
    page.should_not have_content(@page.name)
    page.should_not have_link(@page.relative_link_to_self)
    visit @page.relative_link_to_self
    page.should have_content('404 Not found')
  end

  it 'should allow me to publish my website and inform middle, last name and event and show me info bar' do
    @page = upload_page(:name => 'Joana',
                        :middle_initial => 'Silva',
                        :last_name => 'Sauro',
                        :event => 'Event1',
                        :html => 'oi!')
    assert_upload_is_ok(@page)
  end

  it 'should allow me to update my website when I provide the same information' do
    upload_page(:name => 'Joana',
                :middle_initial => 'Silva',
                :last_name => 'Sauro',
                :event => 'Event1',
                :html => 'oi!')
    @page = upload_page(:name => 'Joana',
                        :middle_initial => 'Silva',
                        :last_name => 'Sauro',
                        :event => 'Event1',
                        :html => 'Updated brow!')
    assert_upload_is_ok(@page)
  end

  pending 'should autocomplete event code with previous inputed values' do
    upload_page(:name => 'Joana',
                :event => 'Event1',
                :html => 'oi!')
    upload_page(:name => 'Paula',
                :event => 'Event2',
                :html => 'hi there!')
    visit '/'
    fill_in 'event', :with => 'Event'
    page.should have_css('.ui-menu-item')
  end

  it 'should be able to filter list by events' do
    upload_page(:name => 'Joana',
                :event => 'Event1',
                :html => 'oi!')
    upload_page(:name => 'Paula',
                :event => 'Event2',
                :html => 'hi there!')

    visit '/list'
    page.should have_content 'Joana'
    page.should have_content 'Paula'

    page.select 'Event1', :from => 'Filter by Event'
    page.find("td:contains('Joana')").should be_visible
    page.find("td:contains('Paula')").should_not be_visible

    page.select 'Event2', :from => 'Filter by Event'
    page.find("td:contains('Joana')").should_not be_visible
    page.find("td:contains('Paula')").should be_visible
  end

  it 'should display previous entered information on validation error' do
    params = { :name => 'Joana',
               :middle_initial => 'Silva',
               :last_name => 'Sauro',
               :event => 'Event1',
               :html => '' }
    upload_page(params)
    page.find_field('name').value.should == params[:name]
    page.find_field('middle_initial').value.should == params[:middle_initial]
    page.find_field('last_name').value.should == params[:last_name]
    page.find_field('event').value.should == params[:event]
  end

  it 'should display page preview on list' do
    @page = upload_page(:name => 'Joana',
                        :middle_initial => 'Silva',
                        :last_name => 'Sauro',
                        :event => 'Event1',
                        :html => 'oi!')
    visit '/list'
    page.find('.preview-link').click
    page.find('#preview-date').text.should == @page.created_at.strftime("%m/%d/%Y")
    page.find('#preview-event').text.should == @page.event
    page.find('#preview-name').text.should == @page.full_name.strip
    page.find('#preview-link').text.should == @page.relative_pretty_link_to_self
    page.find('#preview').text.should == @page.content
  end

  it 'should let me favorite and unfavorite pages' do
    @page = upload_page(:name => 'Joana',
                        :html => 'oi!')
    visit '/list'
    page.find('.star-it').click
    page.find('.star-it').should_not be_visible
    page.find('.starred').should be_visible

    visit '/list'
    page.find('.star-it').should_not be_visible
    page.find('.starred').should be_visible

    page.find('.starred').click
    page.find('.starred').should_not be_visible
    page.find('.star-it').should be_visible

    visit '/list'
    page.find('.starred').should_not be_visible
    page.find('.star-it').should be_visible
  end
end

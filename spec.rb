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
  page.click_link 'HTML'
  fill_in 'html', :with => params[:html]
  click_button 'Publish my website'
  Page.where(:name => params[:name]).first
end

describe 'Black Girls Code Website Publisher', :js => true do
  it 'should allow me to publish my website' do
    @page = upload_page(:name => 'Joana',
                        :html => 'oi!')
    page.should have_content @page.content
    visit @page.relative_link_to_self
    page.should have_content @page.content
  end

  it 'should display info bar when page is uploaded' do
    @page = upload_page(:name => 'Joana',
                        :html => 'oi!')
    page.find('#info_panel').should be_visible
    page.click_link 'close'
    page.find('#info_panel').should_not be_visible
    visit @page.relative_link_to_self
    page.should_not have_css('#info_panel')
  end

  it 'should display info bar when page is uploaded for new page url format' do
    @page = upload_page(:name => 'Joana',
                        :middle_initial => 'Silva',
                        :last_name => 'Sauro',
                        :event => 'Event1',
                        :html => 'oi!')
    page.find('#info_panel').should be_visible
    page.click_link 'close'
    page.find('#info_panel').should_not be_visible
    visit @page.relative_link_to_self
    page.should_not have_css('#info_panel')
  end

  it 'should allow me to publish my website using a file' do
    visit '/'
    fill_in 'name', :with => 'Joana'
    page_file = Tempfile.new('mypage.html')
    page_file.write 'oi!'
    page_file.flush
    page.click_link 'File'
    attach_file('page', page_file.path)
    click_button 'Publish my website'
    page.should have_css('#info_panel')
    page.should have_content 'oi!'
    visit Page.first.relative_link_to_self
    page.should_not have_css('#info_panel')
    page.should have_content 'oi!'
  end

  it 'should be able to import website from link' do
    visit '/'
    fill_in 'name', :with => 'Joana'
    page.click_link 'HTML'
    fill_in 'html', :with => 'Coé'
    click_button 'Publish my website'
    page.should have_css('#info_panel')

    visit '/'
    fill_in 'name', :with => 'Augusta'
    host = Capybara.current_session.driver.rack_server.host
    port = Capybara.current_session.driver.rack_server.port
    page.click_link 'Link'
    fill_in 'link', :with => "http://#{host}:#{port}#{Page.first.relative_pretty_link_to_self}"
    click_button 'Publish my website'

    page.should have_css('#info_panel')
    page.should have_content 'Coé'
    visit Page.first.relative_link_to_self
    page.should_not have_css('#info_panel')
    page.should have_content 'Coé'
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
    visit '/'
    fill_in 'name', :with => 'Joana'
    fill_in 'middle_initial', :with => 'Silva'
    fill_in 'last_name', :with => 'Sauro'
    fill_in 'event', :with => 'BlackGirlsCodeSanFrancisco912837657894'
    page.click_link 'HTML'
    fill_in 'html', :with => 'oi!'
    click_button 'Publish my website'
    @page = Page.first
    visit '/list'
    page.evaluate_script('window.confirm = function() { return true; }')
    page.find('#enable-delete .icon-trash').click
    page.find('.delete .icon-trash').click
    page.should_not have_content(@page.name)
    page.should_not have_link(@page.relative_link_to_self)
    visit @page.relative_link_to_self
    page.should have_content('404 Not found')
  end

  it 'should allow me to publish my website and inform middle, last name and event' do
    visit '/'
    fill_in 'name', :with => 'Joana'
    fill_in 'middle_initial', :with => 'Silva'
    fill_in 'last_name', :with => 'Sauro'
    fill_in 'event', :with => 'BlackGirlsCodeSanFrancisco912837657894'
    page.click_link 'HTML'
    fill_in 'html', :with => 'oi!'
    click_button 'Publish my website'
    page.should have_css('#info_panel')
    page.should have_content 'oi!'
    visit Page.first.relative_link_to_self
    page.should_not have_css('#info_panel')
    page.should have_content 'oi!'
  end

  it 'should allow me to update my website when I provide the same information' do
    visit '/'
    fill_in 'name', :with => 'Joana'
    fill_in 'middle_initial', :with => 'Silva'
    fill_in 'last_name', :with => 'Sauro'
    fill_in 'event', :with => 'BlackGirlsCodeSanFrancisco912837657894'
    page.click_link 'HTML'
    fill_in 'html', :with => 'oi!'
    click_button 'Publish my website'

    visit '/'
    fill_in 'name', :with => 'Joana'
    fill_in 'middle_initial', :with => 'Silva'
    fill_in 'last_name', :with => 'Sauro'
    fill_in 'event', :with => 'BlackGirlsCodeSanFrancisco912837657894'
    page.click_link 'HTML'
    fill_in 'html', :with => 'Updated!'
    click_button 'Publish my website'

    page.should have_css('#info_panel')
    page.should have_content 'Updated!'
    visit Page.first.relative_link_to_self
    page.should_not have_css('#info_panel')
    page.should have_content 'Updated!'
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
    @page = upload_page(:name => 'Joana',
                        :middle_initial => 'Silva',
                        :last_name => 'Sauro',
                        :event => 'Event1',
                        :html => '')
    page.find_field('name').value.should == 'Joana'
    page.find_field('middle_initial').value.should == 'Silva'
    page.find_field('last_name').value.should == 'Sauro'
    page.find_field('event').value.should == 'Event1'
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
    page.find('#preview').text.should == 'oi!'
  end

  it 'should let me star pages' do
  end
end

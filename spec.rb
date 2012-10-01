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

def upload_page_and_assert_data_was_saved(params, success = true)
  visit '/'
  fill_in 'name', :with => params[:name] if params[:name]
  fill_in 'middle_initial', :with => params[:middle_initial] if params[:middle_initial]
  fill_in 'last_name', :with => params[:last_name] if params[:last_name]
  fill_in 'event', :with => params[:event] if params[:event]
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

  if (success)
    page.should have_css('#info_panel')
    uploadedPage = Page.where(:name => params[:name]).first
    uploadedPage.name.should == params[:name].to_s
    uploadedPage.middle_initial.should == params[:middle_initial].to_s
    uploadedPage.last_name.should == params[:last_name].to_s
    if params[:html]
      uploadedPage.content.should == params[:html]
    end
    if params[:link]
      uploadedPage.content.should == content_from_link(params[:link])
    end
    if params[:page]
      uploadedPage.content.should == File.read(params[:page])
    end
    return uploadedPage
  end
end

def url
  if Capybara.current_session.driver.class == Capybara::Driver::Webkit
    host = URI(Capybara.current_session.driver.browser.url).host
    port = URI(Capybara.current_session.driver.browser.url).port
  else
    host = Capybara.current_session.driver.rack_server.host
    port = Capybara.current_session.driver.rack_server.port
  end
  "http://#{host}:#{port}"
end

def assert_upload_is_ok(uploaded_page)
  if Capybara.current_session.driver.class == Capybara::Driver::Webkit
    host = URI(Capybara.current_session.driver.browser.url).host
    port = URI(Capybara.current_session.driver.browser.url).port
  else
    host = Capybara.current_session.driver.rack_server.host
    port = Capybara.current_session.driver.rack_server.port
  end
  link = "#{url}#{uploaded_page.relative_link_to_self}"
  pretty_link = "#{url}#{uploaded_page.relative_pretty_link_to_self}"
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

  it 'publishes my website and show me info bar with site address' do
    @page = upload_page_and_assert_data_was_saved(:name => 'Cecilia',
                                                  :html => 'Eaí Bob!')

    assert_upload_is_ok(@page)
  end

  it 'allows me to publish my website using a file' do
    page_file = Tempfile.new('mypage.html')
    page_file.write 'oi!'
    page_file.flush

    @page = upload_page_and_assert_data_was_saved(:name => 'Cecilia',
                                                  :page => page_file.path)

    assert_upload_is_ok(@page)
  end

  it 'imports website from link' do
    @page = upload_page_and_assert_data_was_saved(:name => 'Joana',
                                                  :html => 'oi!')

    link = "#{url}#{Page.first.relative_pretty_link_to_self}/content"

    @page = upload_page_and_assert_data_was_saved(:name => 'Augusta',
                                                  :link => link)

    assert_upload_is_ok(@page)
  end

  it 'shows my page at list page' do
    @page = upload_page_and_assert_data_was_saved(:name => 'Joana',
                                                  :html => 'oi!')
    visit '/list'
    page.find('.date').text.should == @page.created_at.strftime("%m/%d/%Y")
    page.find('.name').text.should == @page.name
    page.should have_link(@page.relative_link_to_self)
  end

  it 'deletes a page from pages list' do
    @page = upload_page_and_assert_data_was_saved(:name => 'Joana',
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

  it 'deletes a page with new url format from pages list' do
    @page = upload_page_and_assert_data_was_saved(:name => 'Joana',
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

  it 'publishes my website and inform middle, last name and event and show me info bar' do
    @page = upload_page_and_assert_data_was_saved(:name => 'Joana',
                                                  :middle_initial => 'Silva',
                                                  :last_name => 'Sauro',
                                                  :event => 'Event1',
                                                  :html => 'oi!')
    assert_upload_is_ok(@page)
  end

  it 'works if I input all fields except for event' do
    @page = upload_page_and_assert_data_was_saved(:name => 'Joana',
                                                  :middle_initial => 'Silva',
                                                  :last_name => 'Sauro',
                                                  :event => '',
                                                  :html => 'oi!')
    assert_upload_is_ok(@page)
  end

  it 'updates my website when I provide the same student information' do
    upload_page_and_assert_data_was_saved(:name => 'Joana',
                                          :middle_initial => 'Silva',
                                          :last_name => 'Sauro',
                                          :event => 'Event1',
                                          :html => 'oi!')
    @page = upload_page_and_assert_data_was_saved(:name => 'Joana',
                                                  :middle_initial => 'Silva',
                                                  :last_name => 'Sauro',
                                                  :event => 'Event1',
                                                  :html => 'Updated brow!')
    assert_upload_is_ok(@page)
  end

  it 'autocompletes event code with previous informed values' do
    upload_page_and_assert_data_was_saved(:name => 'Joana',
                                          :event => 'Event1',
                                          :html => 'oi!')
    upload_page_and_assert_data_was_saved(:name => 'Paula',
                                          :event => 'Event2',
                                          :html => 'hi there!')
    visit '/'
    fill_in 'event', :with => 'Event'
    page.all('.typeahead li').first.text.should == 'Event1'
    page.all('.typeahead li').last.text.should == 'Event2'
  end

  it 'filters list by events' do
    upload_page_and_assert_data_was_saved(:name => 'Joana',
                                          :event => 'Event1',
                                          :html => 'oi!')
    upload_page_and_assert_data_was_saved(:name => 'Paula',
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

  it 'shows previous entered information on validation error' do
    params = { :name => 'Joana',
               :middle_initial => 'Silva',
               :last_name => 'Sauro',
               :event => 'Event1',
               :html => '' }
    upload_page_and_assert_data_was_saved(params, false)
    page.find_field('name').value.should == params[:name]
    page.find_field('middle_initial').value.should == params[:middle_initial]
    page.find_field('last_name').value.should == params[:last_name]
    page.find_field('event').value.should == params[:event]
  end

  it 'shows page preview on list' do
    @page = upload_page_and_assert_data_was_saved(:name => 'Joana',
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

  it 'favorite and unfavorite pages' do
    @page = upload_page_and_assert_data_was_saved(:name => 'Joana',
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

  it 'shows fancy slideshow with featured pages' do
    @page = upload_page_and_assert_data_was_saved(:name => 'Joana',
                                                  :html => 'oi!')

    visit '/list'
    page.find('.star-it').click

    visit '/'
    page.should have_css '.carousel-inner iframe'
    page.evaluate_script("$('.carousel-inner iframe')[0].contentWindow.document.body.innerHTML").should == @page.content
  end
end

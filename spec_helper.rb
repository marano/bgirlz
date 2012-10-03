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

def assert_uploaded_page_is_displayed_within_event(uploaded_page)
  page.within ".event[data-event='#{uploaded_page.event}']" do
    if uploaded_page.event.blank?
      page.should have_css('h4', :text => '<event missing>')
    else
      page.should have_css('h4', :text => uploaded_page.event)
    end
    page.should have_css('td.name', :text => uploaded_page.name)
    page.should have_css('td.date', :text => uploaded_page.formatted_created_at)
    page.should have_css('td.link', :text => uploaded_page.relative_pretty_link_to_self)
    page.should have_link uploaded_page.relative_link_to_self
  end
end

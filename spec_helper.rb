ENV['RACK_ENV'] = 'test'

require 'tempfile'

require_relative 'bgirlz'

require 'capybara/rspec'
require 'capybara/dsl'

RSpec.configure do |c|
  c.include Capybara::DSL
  c.before do
    PageLink.destroy_all
    Page.destroy_all
    Event.destroy_all
    Capybara.reset_sessions!
  end
end

Capybara.app = Controller

if ENV['headless'] =~ /false/
  Capybara.current_driver = :selenium
  Capybara.javascript_driver = :selenium
else
  Headless.new.start unless RbConfig::CONFIG['host_os'] === /darwin/
  Capybara.current_driver = :webkit
  Capybara.javascript_driver = :webkit
end

include LinkOpener

def upload_page_and_assert_data_was_saved(params, success = true)
  visit '/'
  fill_in 'name', :with => params[:name] if params[:name]
  fill_in 'middle_initial', :with => params[:middle_initial] if params[:middle_initial]
  fill_in 'last_name', :with => params[:last_name] if params[:last_name]
  select params[:event], :from => 'event' unless params[:event].blank?

  if params.has_key?(:enable_comments)
    if params[:enable_comments]
      check('enable_comments')
    else
      uncheck('enable_comments')
    end
  end

  if params[:html]
    click_link 'HTML'
    fill_in 'html', :with => params[:html]
  end
  if params[:link]
    click_link 'Link'
    fill_in 'link', :with => params[:link]
  end
  if params[:page]
    click_link 'File'
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
    if params.has_key?(:enable_comments)
      uploadedPage.enable_comments.should == params[:enable_comments]
    else
      uploadedPage.should_not be_enable_comments
    end
    return uploadedPage
  end
end

def host
  if Capybara.current_session.driver.class == Capybara::Driver::Webkit
    Capybara.current_session.driver.instance_variable_get(:@rack_server).host
  else
    Capybara.current_session.driver.rack_server.host
  end
end

def port
  if Capybara.current_session.driver.class == Capybara::Driver::Webkit
    Capybara.current_session.driver.instance_variable_get(:@rack_server).port
  else
    Capybara.current_session.driver.rack_server.port
  end
end

def url
  "http://#{host}:#{port}"
end

def assert_page_is_displayed(uploaded_page)
  page.should have_content uploaded_page.content
  if uploaded_page.enable_comments
    page.should have_css '#comments'
    page.find('#comments').find('.fb-comments')['data-href'].should == uploaded_page.original_link_to_self(Request.new)
  else
    page.should_not have_css '#comments'
  end
end

def assert_upload_is_ok(uploaded_page)
  assert_page_is_displayed(uploaded_page)

  link = "#{url}#{uploaded_page.relative_link_to_self}"
  pretty_link = "#{url}#{uploaded_page.relative_pretty_link_to_self}"
  page.should have_content pretty_link
  page.find('a#link-to-self')['href'].should == link

  find('#info_panel').should be_visible
  click_link 'close'
  find('#info_panel').should_not be_visible

  visit uploaded_page.relative_link_to_self

  page.should_not have_css('#info_panel')
  assert_page_is_displayed(uploaded_page)
end

class Request
  def host_with_port
    "#{host}:#{port}"
  end
end

def assert_uploaded_page_is_displayed_within_event(uploaded_page)
  within_event uploaded_page.event do
    if uploaded_page.event.blank?
      page.should have_css('h4', :text => '<event missing>')
    else
      page.should have_css('h4', :text => uploaded_page.event)
    end
    if find('.event-expand').visible?
      find('.event-expand').click
    end
    page.should have_css('td.name', :text => uploaded_page.full_name)
    page.should have_css('td.date', :text => uploaded_page.formatted_created_at)
    page.should have_css('td.link', :text => uploaded_page.relative_pretty_link_to_self)
    page.should have_link uploaded_page.relative_link_to_self
  end
end

def expand_event(event)
  within_event(event) { find('.event-expand').click }
end

def hover_event_header(event)
  event_div_locator = ".event[data-event='#{event}']"
  page.execute_script("$(\"#{event_div_locator}\").find('thead').find('tr').trigger('mouseenter');")
end

def hover_out_event_header(event)
  event_div_locator = ".event[data-event='#{event}']"
  page.execute_script("$(\"#{event_div_locator}\").find('thead').find('tr').trigger('mouseout');")
end

def hover_page_row(student_page)
  page.execute_script("$('.page').trigger('mouseenter')")
end

def hover_out_page_row(student_page)
  page.execute_script("$('.page').trigger('mouseout')")
end

def collapse_event(event)
  within_event(event) { find('.event-collapse').click }
end

def within_event(event)
  within ".event[data-event='#{event}']" do
    yield
  end
end

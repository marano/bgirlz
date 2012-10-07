# encoding: utf-8

require_relative 'spec_helper'

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

  it 'publishes my website and inform middle, last name and event and show me info bar' do
    @page = upload_page_and_assert_data_was_saved(:name => 'Joana',
                                                  :middle_initial => 'Silva',
                                                  :last_name => 'Sauro',
                                                  :event => 'Event1',
                                                  :html => 'oi!')
    assert_upload_is_ok(@page)
  end

  it 'shows my page at list page organized by event' do
    @page1 = Page.create!(:name => 'Joana', :middle_initial => 'S', :content => 'oi!')
    @page2 = Page.create!(:name => 'Paula', :event => 'BGCChicago', :content => 'olá!')
    @page3 = Page.create!(:name => 'Jaqueline', :event => 'BGCChicago', :content => 'como vai?')
    @page4 = Page.create!(:name => 'Aloka', :middle_initial => 'V', :last_name => 'Crazy', :event => 'BGCNY', :content => 'Eaí!')

    visit '/list'

    assert_uploaded_page_is_displayed_within_event(@page1)
    assert_uploaded_page_is_displayed_within_event(@page2)
    assert_uploaded_page_is_displayed_within_event(@page3)
    assert_uploaded_page_is_displayed_within_event(@page4)
  end

  it 'deletes a page from pages list' do
    @page1 = Page.create!(:name => 'Joana', :event => 'Event1', :content => 'oi!')
    @page2 = Page.create!(:name => 'Maria', :event => 'Event2', :content => 'oi!')
    @page3 = Page.create!(:name => 'Paula', :content => 'oi!')

    visit '/list'

    assert_uploaded_page_is_displayed_within_event(@page1)
    assert_uploaded_page_is_displayed_within_event(@page2)

    within ".event[data-event='#{@page3.event}']" do
      find('.enable-delete .icon-trash').click
    end

    within ".event[data-event='#{@page1.event}']" do
      find('.enable-delete .icon-trash').should be_visible
      find(".delete").should_not be_visible
    end

    within ".event[data-event='#{@page2.event}']" do
      find('.enable-delete .icon-trash').should be_visible
      find(".delete").should_not be_visible
    end

    within ".event[data-event='#{@page3.event}']" do
      find('.enable-delete .icon-trash').should_not be_visible
      find(".delete").should be_visible
      evaluate_script('window.confirm = function() { return true; }')
      find('.delete .icon-trash').click
    end

    page.should_not have_link(@page3.relative_link_to_self)

    assert_uploaded_page_is_displayed_within_event(@page1)
    assert_uploaded_page_is_displayed_within_event(@page2)

    visit @page3.relative_link_to_self
    page.should have_content('404 Not found')
  end

  it 'deletes a page with new url format from pages list' do
    @page = Page.create!(:name => 'Joana', :middle_initial => 'Silva', :last_name => 'Sauro', :event => 'Event1', :content => 'oi!')

    visit '/list'

    within ".event[data-event='#{@page.event}']" do
      find('.enable-delete .icon-trash').click
      evaluate_script('window.confirm = function() { return true; }')
      find('.delete .icon-trash').click
    end

    page.should_not have_link(@page.relative_link_to_self)
    visit @page.relative_link_to_self
    page.should have_content('404 Not found')
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
    Page.create!(:name => 'Joana', :event => 'Event1', :content => 'oi!')
    Page.create!(:name => 'Marcela', :event => 'Event1', :content => 'ei!')
    Page.create!(:name => 'Paula', :event => 'Event2', :content => 'hi there!')

    visit '/'

    fill_in 'event', :with => 'Event'

    events = all('.typeahead li').map(&:text)

    events.size.should == 2

    events.should include 'Event1'
    events.should include 'Event2'
  end

  it 'filters list by events' do
    Page.create!(:name => 'Joana', :event => 'Event1', :content => 'oi!')
    Page.create!(:name => 'Paula', :event => 'Event2', :content => 'hi there!')

    visit '/list'

    page.should have_content 'Joana'
    page.should have_content 'Paula'

    select 'Event1', :from => 'Filter by Event'
    find("td:contains('Joana')").should be_visible
    find("td:contains('Paula')").should_not be_visible

    select 'Event2', :from => 'Filter by Event'
    find("td:contains('Joana')").should_not be_visible
    find("td:contains('Paula')").should be_visible
  end

  it 'shows previous entered information on validation error' do
    params = { :name => 'Joana',
               :middle_initial => 'Silva',
               :last_name => 'Sauro',
               :event => 'Event1',
               :html => '' }
    upload_page_and_assert_data_was_saved(params, false)
    find_field('name').value.should == params[:name]
    find_field('middle_initial').value.should == params[:middle_initial]
    find_field('last_name').value.should == params[:last_name]
    find_field('event').value.should == params[:event]
  end

  it 'shows page preview on list' do
    @page = Page.create(:name => 'Joana', :middle_initial => 'Silva', :last_name => 'Sauro', :event => 'Event1', :content => 'oi!')
    visit '/list'
    page.execute_script("$('.page').trigger('mouseenter')")
    find('.preview-link').click
    find('#preview-date').text.should == @page.created_at.strftime("%m/%d/%Y")
    find('#preview-event').text.should == @page.event
    find('#preview-name').text.should == @page.full_name.strip
    find('#preview-link').text.should == @page.relative_pretty_link_to_self
    evaluate_script("$('#preview iframe')[0].contentWindow.document.body.innerHTML").should == @page.content
  end

  it 'favorite and unfavorite pages' do
    @page = Page.create!(:name => 'Joana', :content => 'oi!')

    visit '/list'
    find('.star-it').should_not be_visible
    find('.starred').should_not be_visible
    page.execute_script("$('.page').trigger('mouseenter');")
    find('.star-it').should be_visible
    find('.star-it').click
    find('.star-it').should_not be_visible
    find('.starred').should be_visible

    page.execute_script("$('.page').trigger('mouseout');")
    find('.star-it').should_not be_visible
    find('.starred').should be_visible

    visit '/list'
    find('.star-it').should_not be_visible
    find('.starred').should be_visible
    page.execute_script("$('.page').trigger('mouseenter');")
    find('.star-it').should_not be_visible
    find('.starred').should be_visible

    find('.starred').click
    find('.starred').should_not be_visible
    find('.star-it').should be_visible
    page.execute_script("$('.page').trigger('mouseout');")
    find('.starred').should_not be_visible
    find('.star-it').should_not be_visible

    visit '/list'
    find('.starred').should_not be_visible
    find('.star-it').should_not be_visible
    page.execute_script("$('.page').trigger('mouseenter');")
    find('.starred').should_not be_visible
    find('.star-it').should be_visible
  end

  it 'shows fancy slideshow with featured pages' do
    @page = Page.create!(:name => 'Joana', :content => 'oi!')

    visit '/list'
    page.execute_script("$('.page').trigger('mouseenter');")
    find('.star-it').click

    visit '/'
    page.should have_css '.carousel-inner iframe'
    evaluate_script("$('.carousel-inner iframe')[0].contentWindow.document.body.innerHTML").should == @page.content
  end

  pending 'allow me to move page to another event' do
    @page1 = Page.create!(:name => 'Joana', :event => 'Event1', :content => 'oi!')
    @page2 = Page.create!(:name => 'Claudia', :event => 'Event2', :content => 'hi!')
    @page3 = Page.create!(:name => 'Hyohana', :event => 'Event3', :content => 'hello!')

    visit '/list'

    first_event_div = page.find(".event[data-event=#{@page1.event}]")
    second_event_div = page.find(".event[data-event=#{@page2.event}]")
    third_event_div = page.find(".event[data-event=#{@page3.event}]")

    page1_row_locator = ".page[data-page-name=#{@page1.full_name}]"

    page.find(page1_row_locator).find('.move-page').drag_to(second_event_div)
    page.find(page1_row_locator).find('.move-page').drag_to(third_event_div)

    first_event_div.should_not have_css page1_row_locator
    second_event_div.should_not have_css page1_row_locator
    third_event_div.should have_css page1_row_locator

    @page1.reload.event.should == @page3.event

    visit '/list'

    assert_uploaded_page_is_displayed_within_event(@page1)
  end

  it 'shows when page contains image content' do
    @page_with_image = Page.create!(:name => 'Joana', :content => "meet me <img src='/me.jpg'/>!")
    @page_with_video = Page.create!(:name => 'Ana', :content => "meet me <iframe src='http://www.youtube.com/embed/132' />!")
    @page_with_music = Page.create!(:name => 'Cecilia', :content => "play this <iframe src='http://www.miniclip.com/games/soccer-stars/en/webgame.php' />!")
    @page_with_stylesheet = Page.create!(:name => 'Aloka', :content => "im hipister <style>font-face: helvetica</style>")
    @page_with_facebook_comments = Page.create!(:name => 'Maria', :enable_comments => true, :content => "quer falar do que?")
    @page_with_html_errors = Page.create!(:name => 'Augusta', :content => "here <a")

    visit '/list'

    page.find(".page[data-page-name=#{@page_with_image.name}]").should have_css 'i.has-image'
    page.find(".page[data-page-name=#{@page_with_video.name}]").should have_css 'i.has-video'
    page.find(".page[data-page-name=#{@page_with_music.name}]").should have_css 'i.has-music'
    page.find(".page[data-page-name=#{@page_with_stylesheet.name}]").should have_css 'i.has-stylesheet'
    page.find(".page[data-page-name=#{@page_with_facebook_comments.name}]").should have_css 'i.has-facebook-comments'
    page.find(".page[data-page-name=#{@page_with_html_errors.name}]").should have_css 'i.has-html-errors'
  end
end

# encoding: utf-8

require_relative 'spec_helper'

describe 'Black Girls Code Website Publisher', :js => true do

  it 'publishes my website and show me info bar with site address' do
    @page = upload_page_and_assert_data_was_saved(:name => 'Cecilia',
                                                  :html => 'Eaí Bob!')

    assert_upload_is_ok(@page)
  end

  it 'properly displays pages with spaces in the name' do
    @page = Page.create!(:name => 'Ana Cecília', :content => 'Eaws!')
    visit @page.relative_link_to_self
    assert_page_is_displayed(@page)
  end

  it 'keeps the old link after page link changes' do
    @page = upload_page_and_assert_data_was_saved(:name => 'Cecilia',
                                                  :html => 'Eaí Bob!')

    old_link = @page.relative_link_to_self

    @page.name = 'Ana Cecília'
    @page.save

    page.visit old_link

    assert_page_is_displayed(@page)
  end

  it 'add facebook comments to my website' do
    @page = upload_page_and_assert_data_was_saved(:name => 'Cecilia',
                                                  :enable_comments => true,
                                                  :html => 'Eaí Bob!')

    assert_upload_is_ok(@page)
  end

  it 'uses original url for facebook comment href-url parameter after page link changes' do
    @page = upload_page_and_assert_data_was_saved(:name => 'Cecilia',
                                                  :enable_comments => true,
                                                  :html => 'Eaí Bob!')

    @page.name = 'AnaCecilia'
    @page.save

    visit @page.relative_link_to_self

    assert_page_is_displayed(@page)
  end

  it 'should allow other page to have the same url if my page is deleted' do
    @page = Page.create!(:name => 'Aloka', :middle_initial => 'V', :last_name => 'Crazy', :event => 'BGCNY', :content => 'Eaí!')
    @page.destroy
    @page = Page.create!(:name => 'Aloka', :middle_initial => 'V', :last_name => 'Crazy', :event => 'BGCNY', :content => 'How are you doing?')

    visit @page.relative_link_to_self

    assert_page_is_displayed(@page)
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
    Event.create :name => 'Event1'
    @page = upload_page_and_assert_data_was_saved(:name => 'Joana',
                                                  :middle_initial => 'Silva',
                                                  :last_name => 'Sauro',
                                                  :event => 'Event1',
                                                  :html => 'oi!')
    assert_upload_is_ok(@page)
  end

  it 'changes page url format if page attributes are updated' do
    @page = Page.create!(:name => 'Joana', :content => 'oi!')

    @page.send(:new_url_format?).should be_false

    @page.middle_initial = 'C'
    @page.last_name = 'Serra'
    @page.event = 'SuperHTML'
    @page.save

    @page.send(:new_url_format?).should be_true

    visit @page.relative_link_to_self

    assert_page_is_displayed(@page)

    @page = Page.create!(:name => 'Aloka', :middle_initial => 'V', :last_name => 'Crazy', :event => 'BGCNY', :content => 'Eaí!')

    @page.send(:new_url_format?).should be_true

    @page.middle_initial = ''
    @page.save

    @page.send(:new_url_format?).should be_false

    visit @page.relative_link_to_self

    assert_page_is_displayed(@page)
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

  it 'show event pages count' do
    @page1 = Page.create!(:name => 'Joana', :event => 'Event1', :content => 'oi!')
    @page2 = Page.create!(:name => 'Bruna', :event => 'Event2', :content => 'hello!')
    @page3 = Page.create!(:name => 'Karina', :event => 'Event2', :content => 'whatsup!')

    visit '/list'

    within_event(@page1.event) do
      find('.event-page-count').should have_content '1 page'
    end

    within_event(@page2.event) do
      find('.event-page-count').should have_content '2 pages'
    end
  end

  it 'shows pages when event is expanded' do
    @page = Page.create!(:name => 'Joana', :content => 'oi!')

    visit '/list'

    within_event(@page.event) do
      find('.pages').should_not be_visible
    end

    expand_event(@page.event)

    within_event(@page.event) do
      find('.pages').should be_visible
    end

    collapse_event(@page.event)

    within_event(@page.event) do
      find('.pages').should_not be_visible
    end
  end

  it 'deletes a page from pages list' do
    @page1 = Page.create!(:name => 'Joana', :event => 'Event1', :content => 'oi!')
    @page2 = Page.create!(:name => 'Maria', :event => 'Event2', :content => 'oi!')
    @page3 = Page.create!(:name => 'Paula', :content => 'oi!')

    visit '/list'

    assert_uploaded_page_is_displayed_within_event(@page1)
    assert_uploaded_page_is_displayed_within_event(@page2)

    expand_event(@page3.event)

    within_event @page3.event do
      find('.enable-delete').should_not be_visible
      hover_event_header(@page3.event)
      find('.enable-delete').should be_visible
      hover_out_event_header(@page3.event)
      find('.enable-delete').should_not be_visible
      hover_event_header(@page3.event)
      find('.enable-delete .icon-trash').click
    end

    within_event @page1.event do
      find('.enable-delete').should_not be_visible
      find(".delete").should_not be_visible
    end

    within_event @page2.event do
      find('.enable-delete').should_not be_visible
      find(".delete").should_not be_visible
    end

    within_event @page3.event do
      find('.enable-delete').should_not be_visible
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

    expand_event(@page.event)
    hover_event_header(@page.event)

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
    Event.create(:name => 'Event1')
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

  it 'selects event from list of events' do
    Event.create(:name => 'Event1')
    Event.create(:name => 'Event2')
    Page.create!(:name => 'Joana', :event => 'Event1', :content => 'oi!')
    Page.create!(:name => 'Marcela', :event => 'Event1', :content => 'ei!')
    Page.create!(:name => 'Paula', :event => 'Event2', :content => 'hi there!')

    visit '/'

    page.should have_css "option[value=Event1]"
    page.should have_css "option[value=Event2]"
  end

  it 'shows previous entered information on validation error' do
    Event.create(:name => 'Event1')
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
    expand_event(@page.event)
    hover_page_row(@page)
    find('.preview-link').click
    page.should have_css('#preview', visible: true)
    evaluate_script("$('#preview iframe')[0].contentWindow.document.body.innerHTML").should == @page.content
  end

  it 'favorite and unfavorite pages' do
    @page = Page.create!(:name => 'Joana', :content => 'oi!')

    visit '/list'
    expand_event(@page.event)
    find('.star-it').should_not be_visible
    find('.starred').should_not be_visible
    hover_page_row(@page)
    find('.star-it').should be_visible
    find('.star-it').click
    find('.star-it').should_not be_visible
    find('.starred').should be_visible

    hover_out_page_row(@page)
    find('.star-it').should_not be_visible
    find('.starred').should be_visible

    visit '/list'
    expand_event(@page.event)
    find('.star-it').should_not be_visible
    find('.starred').should be_visible
    hover_page_row(@page)
    find('.star-it').should_not be_visible
    find('.starred').should be_visible

    find('.starred').click
    find('.starred').should_not be_visible
    find('.star-it').should be_visible
    hover_out_page_row(@page)
    find('.starred').should_not be_visible
    find('.star-it').should_not be_visible

    visit '/list'
    expand_event(@page.event)
    find('.starred').should_not be_visible
    find('.star-it').should_not be_visible
    hover_page_row(@page)
    find('.starred').should_not be_visible
    find('.star-it').should be_visible
  end

  it 'shows fancy slideshow with featured pages' do
    @page = Page.create!(:name => 'Joana', :content => 'oi!', :favorite => true)
    link = @page.original_link_to_self(Request.new)

    visit '/'

    page.should have_css '.carousel-inner iframe'
    evaluate_script("$('.carousel-inner iframe')[0].contentWindow.document.body.innerHTML").should == @page.content
    page.find('#student-name').should have_css ".fb-like[data-href='#{link}']"
  end

  it 'displays embedded featured pages' do
    @page = Page.create!(:name => 'Joana', :content => 'oi!', :favorite => true)
    link = @page.original_link_to_self(Request.new)

    visit '/featured_pages/embedded'

    page.should have_css '.carousel-inner iframe'
    evaluate_script("$('.carousel-inner iframe')[0].contentWindow.document.body.innerHTML").should == @page.content
    page.find('#student-name').should have_css ".fb-like[data-href='#{link}']"
  end

  it 'displays event featured pages' do
    @page = Page.create!(:name => 'Joana', :event => 'Awesome', :content => 'oi!', :favorite => true)
    link = @page.original_link_to_self(Request.new)

    visit '/list'
    within_event(@page.event) { page.find('.event-featured-pages').click }

    page.should have_css '.carousel-inner iframe'
    evaluate_script("$('.carousel-inner iframe')[0].contentWindow.document.body.innerHTML").should == @page.content
    page.find('#student-name').should have_css ".fb-like[data-href='#{link}']"
  end

  it 'allow me to move page to another event' do
    @page1 = Page.create!(:name => 'Joana', :event => 'Event1', :content => 'oi!')
    @page2 = Page.create!(:name => 'Claudia', :event => 'Event2', :content => 'hi!')
    @page3 = Page.create!(:name => 'Hyohana', :event => 'Event3', :content => 'hello!')

    visit '/list'

    expand_event('Event1')
    hover_page_row(@page1)
    drag_page_to_event(@page1, 'Event2')
    expand_event('Event2')
    expand_event('Event3')
    hover_page_row(@page1)
    drag_page_to_event(@page1, 'Event3')

    page.find(event_div_locator('Event1')).should_not have_css page_row_locator(@page1)
    page.find(event_div_locator('Event2')).should_not have_css page_row_locator(@page1)
    page.find(event_div_locator('Event3')).should have_css page_row_locator(@page1)

    @page1.reload.event.should == 'Event3'

    visit '/list'

    assert_uploaded_page_is_displayed_within_event(@page1)
  end

  it 'updates the counter page of event when a page is dragged to another event' do
    @page1 = Page.create!(:name => 'Joana', :event => 'Event1', :content => 'oi!')
    @page2 = Page.create!(:name => 'Claudia', :event => 'Event2', :content => 'hi!')

    visit '/list'

    expand_event('Event1')
    hover_page_row(@page1)
    drag_page_to_event(@page1, 'Event2')

    within_event(@page1.event) do
      find('.event-page-count').should have_content 'no pages'
    end

    within_event(@page2.event) do
      find('.event-page-count').should have_content '2 pages'
    end
  end

  it 'shows when page contains image content' do
    @page_with_image = Page.create!(:name => 'Joana', :content => "meet me <img src='/me.jpg'/>!")
    @page_with_video = Page.create!(:name => 'Ana', :content => "meet me <iframe src='http://www.youtube.com/embed/132' />!")
    @page_with_music = Page.create!(:name => 'Cecilia', :content => "play this <iframe src='http://www.miniclip.com/games/soccer-stars/en/webgame.php' />!")
    @page_with_music_2 = Page.create!(:name => 'Nina', :content => "<iframe frameborder='no' height='166' src='http://w.soundcloud.com/player/?url=http%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F36735760&amp;show_artwork=true' width='100%'></iframe>")
    @page_with_stylesheet = Page.create!(:name => 'Aloka', :content => "im hipister <style>font-face: helvetica</style>")
    @page_with_facebook_comments = Page.create!(:name => 'Maria', :enable_comments => true, :content => "quer falar do que?")
    @page_with_html_errors = Page.create!(:name => 'Augusta', :content => "here <a")

    visit '/list'

    page.find(".page[data-page-name=#{@page_with_image.name}]").should have_css 'i.has-image'
    page.find(".page[data-page-name=#{@page_with_video.name}]").should have_css 'i.has-video'
    page.find(".page[data-page-name=#{@page_with_music.name}]").should have_css 'i.has-music'
    page.find(".page[data-page-name=#{@page_with_music_2.name}]").should have_css 'i.has-music'
    page.find(".page[data-page-name=#{@page_with_stylesheet.name}]").should have_css 'i.has-stylesheet'
    page.find(".page[data-page-name=#{@page_with_facebook_comments.name}]").should have_css 'i.has-facebook-comments'
    page.find(".page[data-page-name=#{@page_with_html_errors.name}]").should have_css 'i.has-html-errors'
  end

  it 'creates new event' do
    visit '/list'
    click_link 'Create Event'
    page.should have_css('input[value=Create]', visible: true)
    fill_in 'Name', :with => 'NewEvent'
    click_button 'Create'
    within_event('NewEvent') do
      find('.event-title').should have_content 'NewEvent'
    end
  end

  it 'edits event name' do
    @page = Page.create!(:name => 'Joana', :event => 'OriginalEvent', :content => 'oi!')

    visit '/list'

    within_event('OriginalEvent') do
      find('.event-edit').click
      find('.event-name-input').set 'NewEventName'
      click_button 'Save'
    end


    within_event('NewEventName') do
      find('.event-expand').find('.event-title').should have_content 'NewEventName'
    end

    expand_event('NewEventName')

    within_event('NewEventName') do
      find('.event-collapse').find('.event-title').should have_content 'NewEventName'
      find('.event-edit').click
      find('.event-name-input').set 'UpdatedEventName'
      click_button 'Save'
    end

    within_event('UpdatedEventName') do
      find('.event-collapse').find('.event-title').should have_content 'UpdatedEventName'
    end

    collapse_event('UpdatedEventName')

    within_event('UpdatedEventName') do
      find('.event-expand').find('.event-title').should have_content 'UpdatedEventName'
    end

    visit '/list'

    within_event('UpdatedEventName') do
      find('.event-expand').find('.event-title').should have_content 'UpdatedEventName'
    end

    expand_event('UpdatedEventName')

    within_event('UpdatedEventName') do
      find('.event-collapse').find('.event-title').should have_content 'UpdatedEventName'
    end
  end

  it 'edits girls name' do
    @page = Page.create!(:name => 'Joana', :content => 'oi!')

    visit '/list'
    expand_event(@page.event)

    hover_page_row(@page)
    page.find('.edit').click
    page.find('#name-input').value.should == 'Joana'
    page.find('#middle-initial-input').value.should == ''
    page.find('#last-name-input').value.should == ''
    fill_in 'name-input', :with => 'Joaninha'
    fill_in 'middle-initial-input', :with => 'C'
    fill_in 'last-name-input', :with => 'Serra'
    page.find('#edit-submit').click

    page.find('.page').find('.name').text.should == 'Joaninha C Serra'

    hover_page_row(@page)
    page.find('.edit').click
    page.find('#name-input').value.should == 'Joaninha'
    page.find('#middle-initial-input').value.should == 'C'
    page.find('#last-name-input').value.should == 'Serra'

    visit '/list'
    expand_event(@page.event)

    page.find('.page').find('.name').text.should == 'Joaninha C Serra'
  end

  it 'shows the delete button for empty events' do
    Event.create(:name => 'POA Black girls code')
    visit '/list'
    within_event('POA Black girls code') do
      page.should have_css '.event-delete'
    end
  end

  it 'delete button deletes empty events' do
    Event.create(:name => 'POA Black girls code')
    visit '/list'
    within_event('POA Black girls code') do
      page.find('.event-delete').click
    end
    page.should_not have_css ".event[data-event='POA Black girls code']"
    visit '/list'
    page.should_not have_css ".event[data-event='POA Black girls code']"
  end

end



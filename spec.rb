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
    @page1 = Page.create!(:name => 'Joana', :content => 'oi!')
    @page2 = Page.create!(:name => 'Paula', :event => 'BGCChicago', :content => 'olá!')
    @page3 = Page.create!(:name => 'Jaqueline', :event => 'BGCChicago', :content => 'como vai?')
    @page4 = Page.create!(:name => 'Aloka', :event => 'BGCNY', :content => 'Eaí!')

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

    within ".event[data-event='#{@page3.event}']" do
      find('.enable-delete .icon-trash').click
    end

    within ".event[data-event='#{@page1.event}']" do
      find('.enable-delete .icon-trash').should be_visible
      page.find(".delete").should_not be_visible
    end

    within ".event[data-event='#{@page2.event}']" do
      find('.enable-delete .icon-trash').should be_visible
      page.find(".delete").should_not be_visible
    end

    within ".event[data-event='#{@page3.event}']" do
      find('.enable-delete .icon-trash').should_not be_visible
      page.find(".delete").should be_visible
      page.find('.delete .icon-trash').click
    end

    page.should_not have_link(@page3.relative_link_to_self)

    visit @page3.relative_link_to_self
    page.should have_content('404 Not found')
  end

  it 'deletes a page with new url format from pages list' do
    @page = Page.create!(:name => 'Joana', :middle_initial => 'Silva', :last_name => 'Sauro', :event => 'Event1', :content => 'oi!')

    visit '/list'

    within ".event[data-event='#{@page.event}']" do
      find('.enable-delete .icon-trash').click
      page.find('.delete .icon-trash').click
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
    Page.create!(:name => 'Paula', :event => 'Event2', :content => 'hi there!')

    visit '/'

    fill_in 'event', :with => 'Event'
    page.all('.typeahead li').first.text.should == 'Event1'
    page.all('.typeahead li').last.text.should == 'Event2'
  end

  it 'filters list by events' do
    Page.create!(:name => 'Joana', :event => 'Event1', :content => 'oi!')
    Page.create!(:name => 'Paula', :event => 'Event2', :content => 'hi there!')

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
    @page = Page.create(:name => 'Joana', :middle_initial => 'Silva', :last_name => 'Sauro', :event => 'Event1', :content => 'oi!')
    visit '/list'
    page.find('.preview-link').click
    page.find('#preview-date').text.should == @page.created_at.strftime("%m/%d/%Y")
    page.find('#preview-event').text.should == @page.event
    page.find('#preview-name').text.should == @page.full_name.strip
    page.find('#preview-link').text.should == @page.relative_pretty_link_to_self
    page.find('#preview').text.should == @page.content
  end

  it 'favorite and unfavorite pages' do
    @page = Page.create!(:name => 'Joana', :content => 'oi!')

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
    @page = Page.create!(:name => 'Joana', :content => 'oi!')

    visit '/list'
    page.find('.star-it').click

    visit '/'
    page.should have_css '.carousel-inner iframe'
    page.evaluate_script("$('.carousel-inner iframe')[0].contentWindow.document.body.innerHTML").should == @page.content
  end
end

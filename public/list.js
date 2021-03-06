$(function () {
  $('.delete').click(function (e) {
    var ok = confirm("Are you sure you want to delete that page?");
    if (ok) {
      $(e.target).closest('form').submit();
    }
    e.preventDefault();
  });

  var currentPreviewPath = null;

  $('.star-it').click(function (event) {
    event.preventDefault();
    $('.star-it').tooltip('hide');
    var row = getParentRow(event.target);
    var path = row.data('favorite-path');
    row.find('.star-it').addClass('hide');
    row.find('.starred').removeClass('hide');
    $.ajax({
      url: path,
      type: 'PUT',
      success: function () {}
    });
  });

  $('.starred').click(function (event) {
    event.preventDefault();
    $('.starred').tooltip('hide');
    var row = getParentRow(event.target);
    var path = row.data('unfavorite-path');
    row.find('.starred').addClass('hide');
    row.find('.star-it').removeClass('hide');
    $.ajax({
      url: path,
      type: 'PUT',
      success: function () {}
    });
  });

  $('.preview-btn').click(function (event) {
    event.preventDefault();

    var row = getParentRow(event.target);
    var topOffset = row.offset().top;

    $('#preview-container').animate({'top': topOffset});

    $('html, body').stop().animate({
      scrollTop: topOffset
    }, 200);

    var path = row.data('page-path');
    var contentPath = row.data('page-content-path');
    if (currentPreviewPath == path) {
      return;
    }
    currentPreviewPath = path;
    $('.on-preview').removeClass('on-preview');
    row.addClass('on-preview');
    $('#preview-container').removeClass('hide');

    $('#preview').addClass('hide');
    $('#loading').removeClass('hide');

    $('#preview').find('iframe').load(function () {
      $('#loading').addClass('hide');
      $('#preview').find('iframe').contents().find('body').css('zoom', '70%')
      $('#preview').removeClass('hide');
      autoResize($('#preview').find('iframe')[0]);
      var topOffset = row.offset().top;

      $('html, body').stop().animate({
        scrollTop: topOffset
      }, 200);
    });
    $('#preview').find('iframe').attr('src', contentPath);
  });

  $('.event-edit').tooltip({placement: 'top', title: 'Edit'});
  $('.event-delete').tooltip({placement: 'top', title: 'Remove Event'});
  $('.event-featured-pages i').tooltip({placement: 'right', title: 'Featured Pages'});

  $('.delete').tooltip({placement: 'right', title: 'Trash it'});
  $('.preview-link').tooltip({placement: 'right', title: 'Preview'});
  $('.starred').tooltip({placement: 'bottom', title: 'Unstar it'});
  $('.star-it').tooltip({placement: 'bottom', title: 'Star it'});
  $('.enable-delete').tooltip({placement: 'right', title: 'Show delete buttons'});
  $('.move-page').tooltip({placement: 'right', title: 'Move page to another event'});
  $('.edit').tooltip({placement: 'right', title: 'Edit'});

  $('.has-image').tooltip({placement: 'bottom', title: 'Image'});
  $('.has-video').tooltip({placement: 'bottom', title: 'Video'});
  $('.has-music').tooltip({placement: 'bottom', title: 'Music'});
  $('.has-stylesheet').tooltip({placement: 'bottom', title: 'Stylesheet'});
  $('.has-facebook-comments').tooltip({placement: 'bottom', title: 'Facebook Comments'});
  $('.has-html-errors').tooltip({placement: 'bottom', title: 'HTML problems'});

  $('.enable-delete').click(function (event) {
    event.preventDefault();
    var eventDiv = getEventDiv(event.target);
    searchTreeFor('.enable-delete', eventDiv).addClass('hide');
    searchTreeFor('.delete', eventDiv).removeClass('hide');
    searchTreeFor('.move-page', eventDiv).addClass('hide');
  });

  $('.page').draggable({scope: 'events', handle: '.move-page', scrollSensitivity: 100, helper: function(event) {
    return $('<div class="drag-cart-item"><table></table></div>').find('table').append($(event.target).closest('tr').clone()).end();
  }});

  $('thead').mouseenter(function (event) {
    searchTreeFor('.show-on-header-hover', getParentRow(event.target)).each(function (index, element) {
      $(element).addClass('hovering');
    });
  }).mouseleave(function (event) {
    searchTreeFor('.show-on-header-hover', getParentRow(event.target)).each(function (index, element) {
      $(element).removeClass('hovering');
    });
  });

  $('.page').mouseenter(function (event) {
    searchTreeFor('.show-on-hover', getParentRow(event.target)).each(function (index, element) {
      $(element).addClass('hovering');
    });
  }).mouseleave(function (event) {
    searchTreeFor('.show-on-hover', getParentRow(event.target)).each(function (index, element) {
      $(element).removeClass('hovering');
    });
  });

  $('.edit').click(function (event) {
    event.preventDefault();
    var row = getParentRow(event.target);
    var editLink = row.find('.edit');
    editLink.addClass('hide')
    editLink.tooltip('hide');
    var path = row.data('update-name-path');
    var name = row.data('page-name');
    var middleInitial = row.data('page-middle-initial');
    var lastName = row.data('page-last-name');
    if(middleInitial == undefined) {
      middleInitial = ''
    }
    if(lastName == undefined) {
      lastName = ''
    }
    var form = $("<form id='edit-form'><input id='name-input' placeholder='First Name' type='text' value='" + name + "' /><input id='middle-initial-input' placeholder='Middle Initial' type='text' value='" + middleInitial + "' /><input id='last-name-input' placeholder='Last Name' type='text' value='" + lastName + "' /><input id='edit-submit' class='btn btn-primary' type='submit' value='Save' /></form>");
    row.find('.name-container').html(form);

    row.find('#edit-form').submit(function (e) {
      e.preventDefault();

      var name = row.find('#name-input').val();
      var middleInitial = row.find('#middle-initial-input').val();
      var lastName = row.find('#last-name-input').val();

      $.ajax({
        url: path,
        type: 'PUT',
        data: { name: name, middle_initial: middleInitial, last_name: lastName },
        success: function () {}
      });

      row.data('page-name', name);
      row.data('page-middle-initial', middleInitial);
      row.data('page-last-name', lastName);

      row.find('.name-container').text(name + ' ' + middleInitial + ' ' + lastName);
      editLink.removeClass('hide');
      row.trigger('mouseout');
    });
  });

  $('.event').each(function (index, eventDiv) {
    bindEvents($(eventDiv));
  });

  $('#event-create-window').on('shown', function () {
    $('#event-create-name').focus();
  });

  $('#event-create-form').submit(function (event) {
    event.preventDefault();
    $('#event-create-window').modal('hide');
    var newEventName = $('#event-create-name').val();
    $('#event-create-name').val('');
    $.ajax({
      url: '/events',
      type: 'POST',
      data: { name: newEventName },
      success: function (eventDiv) {
        eventDiv = $(eventDiv);
        $('#events').prepend(eventDiv);
        bindEvents(eventDiv);
      }
    });
  });

  function bindEvents(eventDiv) {
    pageCounter(eventDiv);

    eventDiv.find('.event-expand').click(function (event) {
      event.preventDefault();
      var eventDiv = getEventDiv(event.target);
      eventDiv.find('.pages').removeClass('hide');
      eventDiv.find('.event-expand').addClass('hide');
      eventDiv.find('.event-collapse').removeClass('hide');
    });

    eventDiv.find('.event-collapse').click(function (event) {
      event.preventDefault();
      var eventDiv = getEventDiv(event.target);
      eventDiv.find('.pages').addClass('hide');
      eventDiv.find('.event-expand').removeClass('hide');
      eventDiv.find('.event-collapse').addClass('hide');
    });

    eventDiv.find('.event-edit').click(function (event) {
      event.preventDefault();
      eventDiv.find('.event-title').addClass('hide');
      eventDiv.find('.event-edit').addClass('hide');
      eventDiv.find('.event-page-count').addClass('hide');
      eventDiv.find('.event-featured-pages').addClass('hide');
      eventDiv.find('.event-featured-pages-disabled').addClass('hide');
      eventDiv.find('.event-edit-form').removeClass('hide');
    });

      eventDiv.find('.event-delete').click(function (event) {
        event.preventDefault();
        var deleteEventPath = eventDiv.attr('data-event-update-name-path');
        $.ajax({
          url: deleteEventPath, 
          type: 'DELETE',
          success: function () {}
        });
        eventDiv.remove();
      });

    eventDiv.find('.event-edit-form').submit(function (event) {
      event.preventDefault();
      var newEventName = eventDiv.find('.event-name-input').val();
      var updateEventNamePath = eventDiv.attr('data-event-update-name-path');
      $.ajax({
        url: updateEventNamePath,
        type: 'PUT',
        data: { name: newEventName },
        success: function (eventJSON) {
          var updatedEvent = $.parseJSON(eventJSON);
          eventDiv.attr('data-event', updatedEvent.name);
          eventDiv.attr('data-event-update-name-path', updatedEvent.link_to_update_name);
        }
      });
      eventDiv.find('.event-title').text(newEventName);
      eventDiv.find('.event-title').removeClass('hide');
      eventDiv.find('.event-edit').removeClass('hide');
      eventDiv.find('.event-page-count').removeClass('hide');
      eventDiv.find('.event-featured-pages').removeClass('hide');
      eventDiv.find('.event-featured-pages-disabled').removeClass('hide');
      eventDiv.find('.event-edit-form').addClass('hide');
    });

    eventDiv.droppable({scope: 'events', hoverClass: 'droppable-active', drop: function (event, ui) {
      $('.drag-cart-item').remove();
      var toEventDiv = $(event.target);
      var pageMovedRow = $(ui.draggable);
      var pageMovedRowOldEvent = pageMovedRow.data('page-event');
      var movedToEvent = toEventDiv.data('event');
      if (pageMovedRowOldEvent == movedToEvent) {
        return;
      }
      pageMovedRow.data('page-event', movedToEvent);
      var fromEventDiv = $(pageMovedRow).closest('.event');
      toEventDiv.find('tbody').append(pageMovedRow);
      updatePageCounter(fromEventDiv, toEventDiv);

      var path = pageMovedRow.data('change-event-path');
      $.ajax({
        url: path,
        type: 'PUT',
        data: { event: movedToEvent },
        success: function () {}
      });
    }});
  }



  function getParentRow(element) {
    if (element.tagName == 'TR') {
      return $(element);
    } else {
      return getParentRow(element.parentElement);
    }
  }

  function getEventDiv(element) {
    if (element.tagName == 'DIV') {
      return $(element);
    } else {
      return getEventDiv(element.parentElement);
    }
  }

  function searchTreeFor(target, tree) {
    var result = tree.find(target);
    if (result) {
      return result;
    } else {
      return searchTreeFor(target.children(), tree)
    }
  }

  function autoResize(iframe) {
    var newheight = iframe.contentWindow.document.body.scrollHeight;
    var newwidth = iframe.contentWindow.document.body.scrollWidth;

    iframe.height = (newheight) + "px";
    iframe.width = (newwidth) + "px";
  }

  function pageCounter(eventDiv) {
    var pageCount = $(eventDiv).find('.page').length;
    var pageCounterMsg;

    if (pageCount > 0) {
      if (pageCount === 1) {
        pageCounterMsg = "1 page";
      } else {
        pageCounterMsg = pageCount + " pages";
      }
    } else {
      pageCounterMsg = "no pages";
    }
    $(eventDiv).closest('.event').find('.event-page-count').text(pageCounterMsg);
  }

  function updatePageCounter(fromEventPage, toEventPage) {
    pageCounter(fromEventPage);
    pageCounter(toEventPage);
  }

});

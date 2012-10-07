$(function () {
  $('.delete').click(function (e) {
    var ok = confirm("Are you sure you want to delete that page?");
    if (ok) {
      $(e.target).parent().parent().submit();
    }
    e.preventDefault();
  });

  $('#filter select').change(filterSelectOnChange);

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

    var date = row.data('page-date');
    var eventName = row.data('page-event');
    var name = row.data('page-name');
    var path = row.data('page-path');
    var contentPath = row.data('page-content-path');
    var prettyUrl = row.data('page-pretty-path');
    if (currentPreviewPath == path) {
      return;
    }
    currentPreviewPath = path;
    $('.on-preview').removeClass('on-preview');
    row.addClass('on-preview');
    $('#preview-container').removeClass('hide');

    $('#preview').addClass('hide');
    $('#loading').removeClass('hide');
    fillInfoField('#preview-date', date);
    fillInfoField('#preview-event', eventName);
    $('#preview-name').text(name);
    $('#preview-link').empty().append($('<a>', {href: path}).text(prettyUrl));

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

  $('.delete').tooltip({placement: 'right', title: 'Trash it'});
  $('.preview-link').tooltip({placement: 'right', title: 'Preview'});
  $('.starred').tooltip({placement: 'bottom', title: 'Unstar it'});
  $('.star-it').tooltip({placement: 'bottom', title: 'Star it'});
  $('.enable-delete').tooltip({placement: 'right', title: 'Show delete buttons'});
  $('.move-page').tooltip({placement: 'right', title: 'Move page to another event'});

  $('.has-image').tooltip({placement: 'bottom', title: 'Image'});
  $('.has-video').tooltip({placement: 'bottom', title: 'Video'});
  $('.has-music').tooltip({placement: 'bottom', title: 'Music'});
  $('.has-stylesheet').tooltip({placement: 'bottom', title: 'Stylesheet'});
  $('.has-facebook-comments').tooltip({placement: 'bottom', title: 'Facebook Comments'});
  $('.has-html-errors').tooltip({placement: 'bottom', title: 'HTML problems'});

  $('.event-link').click(function (event) {
    event.preventDefault();
    var row = getParentRow(event.target);
    var event = row.data('page-event');
    $('#filter-select').val(event);
    filterSelectOnChange();
  });

  $('.enable-delete').click(function (event) {
    event.preventDefault();
    var eventDiv = getEventDiv(event.target);
    searchTreeFor('.enable-delete', eventDiv).hide();
    searchTreeFor('.delete', eventDiv).removeClass('hide');
    searchTreeFor('.move-page', eventDiv).addClass('hide');
  });


  $('.page').draggable({scope: 'events', handle: '.move-page', scrollSensitivity: 100, helper: function(event) {
    return $('<div class="drag-cart-item"><table></table></div>').find('table').append($(event.target).closest('tr').clone()).end();
  }});

  $('.event').droppable({scope: 'events', hoverClass: 'droppable-active', drop: function (event, ui) {
    $('.drag-cart-item').remove();
    var eventDiv = $(event.target);
    var pageMovedRow = $(ui.draggable);
    var pageMovedRowOldEvent = pageMovedRow.data('page-event');
    var movedToEvent = eventDiv.data('event');
    if (pageMovedRowOldEvent == movedToEvent) {
      return;
    }
    pageMovedRow.data('page-event', movedToEvent);
    eventDiv.find('tbody').append(pageMovedRow);
    var path = pageMovedRow.data('change-event-path');
    $.ajax({
      url: path,
      type: 'PUT',
      data: { event: movedToEvent },
      success: function () {}
    });
  }});

  $('.page').mouseenter(function (event) {
    searchTreeFor('.show-on-hover', getParentRow(event.target)).each(function (index, element) {
      $(element).addClass('hovering');
    });
  }).mouseleave(function (event) {
    searchTreeFor('.show-on-hover', getParentRow(event.target)).each(function (index, element) {
      $(element).removeClass('hovering');
    });
  });

  function fillInfoField(field, info) {
    if (info) {
      $(field).text(info);
    } else {
      $(field).text('-');
    }
  }

  function filterSelectOnChange() {
    var filterEvent = $('#filter select option:selected').val();
    $('.page').each(function (index, page) {
      if (!filterEvent) {
        $(page).show();
        return;
      }
      var pageEvent = $(page).data('page-event');
      if (!pageEvent) {
        $(page).hide();
        return;
      }
      if (filterEvent == pageEvent) {
        $(page).show();
      } else {
        $(page).hide();
      }
    });
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
});

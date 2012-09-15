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
    var row = getParentRow(event.target);
    var path = row.data('favorite-path');
    row.find('.star-it').hide();
    row.find('.starred').show();
    $.ajax({
      url: path,
      type: 'PUT',
      success: function () {}
    });
  });

  $('.starred').click(function (event) {
    event.preventDefault();
    var row = getParentRow(event.target);
    var path = row.data('unfavorite-path');
    row.find('.starred').hide();
    row.find('.star-it').show();
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
    var event = row.data('page-event');
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
    $('#preview-container').show();

    $('#preview').hide();
    $('#loading').show();
    fillInfoField('#preview-date', date);
    fillInfoField('#preview-event', event);
    $('#preview-name').text(name);
    $('#preview-link').empty().append($('<a>', {href: path}).text(prettyUrl));

    $('#preview').load(contentPath, function () {
      $('#loading').hide();
      $('#preview').show();
      var topOffset = row.offset().top;

      $('html, body').stop().animate({
        scrollTop: topOffset
      }, 200);
    });
  });

  $('.delete').tooltip({placement: 'left', title: 'Trash it'});
  $('.preview-link').tooltip({placement: 'left', title: 'Preview'});
  $('#enable-delete').tooltip({placement: 'top', title: 'Show delete buttons'});

  $('.event-link').click(function (event) {
    event.preventDefault();
    var row = getParentRow(event.target);
    var event = row.data('page-event');
    $('#filter-select').val(event);
    filterSelectOnChange();
  });

  $('#enable-delete').click(function (event) {
    event.preventDefault();
    $('#enable-delete').hide();
    $('.delete').show();
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
});

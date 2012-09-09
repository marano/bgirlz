$(function () {
  $('.delete').click(function (e) {
    var ok = confirm("Are you sure you want to delete that page?");
    if (ok) {
      $(e.target).parent().parent().submit();
    }
    e.preventDefault();
  });

  $('#filter select').change(filterSelectOnChange);

  var currentPreviewUrl = null;

  $('.preview-btn').click(function (event) {
    event.preventDefault();

    $('html, body').stop().animate({
      scrollTop: 124
    }, 800);

    var row = getParentRow(event.target);
    var date = row.data('page-date');
    var event = row.data('page-event');
    var name = row.data('page-name');
    var url = row.data('page-url');
    var prettyUrl = row.data('page-pretty-url');
    if (currentPreviewUrl == url) {
      return;
    }
    currentPreviewUrl = url;
    $('.on-preview').removeClass('on-preview');
    row.addClass('on-preview');

    $('#preview').hide();
    $('#loading').show();
    fillInfoField('#preview-date', date);
    fillInfoField('#preview-event', event);
    $('#preview-name').text(name);
    $('#preview-link').empty().append($('<a>', {href: url}).text(prettyUrl));

    $('#preview').load(url, function () {
      $('#loading').hide();
      $('#preview').show();
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

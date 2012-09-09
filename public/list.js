$(function () {
  $('.delete').click(function (e) {
    var ok = confirm("Are you sure you want to delete that page?");
    if (ok) {
      $(e.target).parent().parent().submit();
    }
    e.preventDefault();
  });

  $('#filter select').change(function () {
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
  });

  var currentPreviewUrl = null;

  $('.preview-btn').click(function (event) {
    event.preventDefault();

    $('html, body').stop().animate({
      scrollTop: 0
    }, 800);

    var row = getParentRow(event.target);
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
    $('#preview-event').text(event);
    $('#preview-name').text(name);
    $('#preview-link').empty().append($('<a>', {href: url}).text(prettyUrl));

    $('#preview').load(url, function () {
      $('#loading').hide();
      $('#preview').show();
    });
  });

  function getParentRow(element) {
    if (element.tagName == 'TR') {
      return $(element);
    } else {
      return getParentRow(element.parentElement);
    }
  }
});

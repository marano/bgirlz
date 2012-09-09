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
});

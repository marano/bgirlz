global_was_here = null;

$(function () {
  if (global_was_here) {
    return;
  };
  global_was_here = true;
  var first_times = $('meta[name=first_time]');
  var first_time  = first_times[first_times.length - 1].content == 'true';
  if (first_time) {
    var page_name = $('meta[name=page_name]')[0].content;
    var page_salt = $('meta[name=page_salt]')[0].content;
    var page_panel_path = $('meta[name=page_panel_path]')[0].content;
    $.get(page_panel_path, function (panel) {
      $('body').prepend($(panel));
    });
    var origin = window.location.origin;
    var pathname = window.location.pathname;
    window.history.pushState(0, '', origin + pathname);
  }
});

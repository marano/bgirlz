$(function () {
  var first_time  = $('meta[name=first_time]')[0].content == 'true';
  if (first_time) {
    var page_name = $('meta[name=page_name]')[0].content;
    var page_salt = $('meta[name=page_salt]')[0].content;
    $.get('/' + page_salt + '/' + page_name + '/panel', function (panel) {
      $('body').prepend($(panel));
    });
    var origin = window.location.origin;
    var pathname = window.location.pathname;
    window.history.pushState(0, '', origin + pathname);
  }
});

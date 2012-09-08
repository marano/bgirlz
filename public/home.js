$(function () {
  $.getJSON('/previous_events', function (events) {
    $('input[name=event]').autocomplete({source: events});
  });
});

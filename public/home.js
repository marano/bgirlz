$(function () {
  $.getJSON('/previous_events', function (events) {
    $('input[name=event]').typeahead({source: events});
  });
});

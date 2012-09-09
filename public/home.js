$(function () {
  $('#name').keypress(validateInput);
  $('#middle-initial').keypress(validateInput);
  $('#last-name').keypress(validateInput);
  $('#event').keypress(validateInput);

  $.getJSON('/previous_events', function (events) {
    $('input[name=event]').typeahead({source: events});
  });

  function validateInput(event) {
    var key = event.keyCode || event.which;
    key = String.fromCharCode( key );
    var regex = /[a-z|A-Z|0-9]|\./;
    if( !regex.test(key) ) {
      event.returnValue = false;
      event.preventDefault();
    }
  }
});

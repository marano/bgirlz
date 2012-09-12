$(function () {
  $('#name').keypress(validateInput);
  $('#middle-initial').keypress(validateInput);
  $('#last-name').keypress(validateInput);
  $('#event').keypress(validateInput);

  addTooltip('#name');
  addTooltip('#middle-initial');
  addTooltip('#last-name');
  addTooltip('#event');

  $.getJSON('/previous_events', function (events) {
    $('input[name=event]').typeahead({source: events});
  });

  function addTooltip(element) {
    $(element).tooltip({delay: {show: 800}, placement: 'right', title: 'Only letters and numbers are allowed. Space and underline are not allowed.'});
  }

  $.getJSON('/featured_pages', function (links) {
    $(links).each(function (index, link) {
      var item = $('<div>');
      item.addClass('item');
      var iFrameId = 'slide' + index;
      var resizeCall = 'autoResize("' + iFrameId + '");';
      var content = $('<iframe>', {id: iFrameId, src: link, onLoad: resizeCall});
      item.append(content);
      $('.carousel-inner').append(item);
    });
    $('#slide').carousel();
    $('#slide').show();
  });

  function validateInput(event) {
    if (event.charCode == 13 || event.charCode == 0) {
      return true;
    }
    var key = event.keyCode || event.which;
    key = String.fromCharCode( key );
    var regex = /[a-z|A-Z|0-9]/;
    if( !regex.test(key) ) {
      event.returnValue = false;
      event.preventDefault();
      $(event.target).tooltip('show');
      setTimeout(function () {
        $(event.target).tooltip('hide');
      }, 3000);
    }
  }
});

function autoResize(id) {
  var newheight = document.getElementById(id).contentWindow.document.body.scrollHeight;
  var newwidth = document.getElementById(id).contentWindow.document.body.scrollWidth;

  document.getElementById(id).height = (newheight) + "px";
  document.getElementById(id).width = (newwidth) + "px";
}

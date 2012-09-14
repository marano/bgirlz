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
    var totalLinks = links.length;
    var linksCount = 0;
    $(links).each(function (index, link) {
      $.get(link, function (response) {
        response = $(response);
        var iframe = response.find('iframe');
        iframe.load(function () { autoResize(iframe[0]); });
        $('.carousel-inner').append(response);
        linksCount = linksCount + 1;
        if (linksCount == totalLinks) {
          $('#slide').carousel();
          $('.carousel-inner').show();
        }
      });
    });
  });

  function autoResize(iframe) {
    var newheight = iframe.contentWindow.document.body.scrollHeight;
    var newwidth = iframe.contentWindow.document.body.scrollWidth;

    iframe.height = (newheight) + "px";
    iframe.width = (newwidth) + "px";
  }

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

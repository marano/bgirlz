$(function () {
  $('#name').keypress(validateInput);
  $('#middle-initial').keypress(validateInput);
  $('#last-name').keypress(validateInput);
  $('#event').keypress(validateInput);

  addTooltip('#name');
  addTooltip('#middle-initial');
  addTooltip('#last-name');
  addTooltip('#event');

  $('#menu a').click(function (event) {
    event.preventDefault();
    var link = getParentLink(event.target);
    var element = $(link.attr('href'));
    var top;

    if (element.length > 0) {
      top = element.offset().top;
    } else {
      top = 0;
    }

    $('html, body').animate({
      scrollTop: top
    }, 800);
  });

  $.getJSON('/previous_events', function (events) {
    $('input[name=event]').typeahead({source: events});
  });

  function addTooltip(element) {
    $(element).tooltip({delay: {show: 800}, placement: 'right', title: 'Only letters and numbers are allowed. Space and underline are not allowed.'});
  }

  $('#slide').carousel();
  $('#slide').carousel('pause');

  $('#slide').on('slid', function () {
    $('#student-name').animate({opacity: '0'}, 80, function () {
      var name = $('.carousel-inner .active').data('page-name');
      if(!$('#student-name').is(':visible')) {
        $('#student-name').show();
      }
      $('#student-name span').text(name);
      $('#student-name').animate({opacity: '1'}, 200);
    });
  });

  $.getJSON('/featured_pages', function (links) {
    var totalLinks = links.length;
    var linksCount = 0;
    $(links).each(function (index, link) {
      $('.bar').css('width', '20%');
      $.get(link, function (response) {
        response = $(response);
        var iframe = response.find('iframe');
        iframe.load(function () {
          autoResize(iframe[0]);
          linksCount = linksCount + 1;
          $('.bar').css('width', ((linksCount / totalLinks * 100) + 20) + '%');
          if (linksCount == totalLinks) {
            $('#loading').hide();
            $('.carousel-inner').show();
            $('#slide').carousel('cycle');
            $('#slide').carousel('next');
          }
        });
        $('.carousel-inner').append(response);
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

  function getParentLink(element) {
    if (element.tagName == 'A') {
      return $(element);
    } else {
      return getParentLink(element.parentElement);
    }
  }
});

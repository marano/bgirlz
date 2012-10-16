$(function () {
  var validateInput = function (event) {
    if (event.charCode === 13 || event.charCode === 0) {
      return true;
    }
    var key = event.keyCode || event.which;
    var keyCode = String.fromCharCode(key);
    var regex = /[a-z|A-Z|0-9]/;
    if (!regex.test(keyCode)) {
      event.returnValue = false;
      event.preventDefault();
      $(event.target).tooltip('show');
      setTimeout(function () {
        $(event.target).tooltip('hide');
      }, 3000);
    }
  };

  $('#name').keypress(validateInput);
  $('#middle-initial').keypress(validateInput);
  $('#last-name').keypress(validateInput);
  $('#event').keypress(validateInput);

  var addTooltip = function (element) {
    $(element).tooltip({delay: {show: 800}, placement: 'right', title: 'Only letters and numbers are allowed. Space and underline are not allowed.'});
  };

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

  $('#slide').carousel();
  $('#slide').carousel('pause');

  $('#slide').on('slid', function () {
    $('#student-name').animate({opacity: '0'}, 80, function () {
      var name = $('.carousel-inner .active').data('page-name');
      var link = $('.carousel-inner .active').data('page-original-link');
      if(!$('#student-name').is(':visible')) {
        $('#student-name').show();
      }
      $('#student-name h4').find('span').text(name);
      $('.fb-like').hide();
      $('.fb-like[data-href="' + link + '"]').show();
      $('#student-name').animate({opacity: '1'}, 200);
    });
  });

  $.getJSON('/featured_pages', function (links) {
    var totalLinks = links.length;
    var linksCount = 0;
    $(links).each(function (index, link) {
      $('.bar').css('width', '20%');
      $.get(link.featured, function (response) {
        response = $(response);
        var iframe = response.find('iframe');
        iframe.load(function () {
          autoResize(iframe[0]);
          linksCount = linksCount + 1;
          $('.bar').css('width', ((linksCount / totalLinks * 100) + 20) + '%');
          if (linksCount == totalLinks) {
            loadFacebook();
            $('#loading').animate({opacity: 0}, 500, function () { $('#loading').hide(); });
            $('.carousel-inner').css('opacity', 0);
            $('.carousel-inner').show();
            $('.carousel-inner').animate({opacity: 1}, 2000);
            $('#slide').carousel('cycle');
            $('#slide').carousel('next');
          }
        });
        $('.carousel-inner').append(response);
        var likeButton = $('<div class="fb-like" data-send="false" data-layout="button_count" data-width="450" data-show-faces="true" data-font="verdana"></div>').hide().attr('data-href', link.self);
        $('#student-name').append(likeButton);
      });
    });
  });

  function autoResize(iframe) {
    var newheight = iframe.contentWindow.document.body.scrollHeight;
    var newwidth = iframe.contentWindow.document.body.scrollWidth;

    iframe.height = (newheight) + "px";
    iframe.width = (newwidth) + "px";
  }

  function getParentLink(element) {
    if (element.tagName == 'A') {
      return $(element);
    } else {
      return getParentLink(element.parentElement);
    }
  }

  function loadFacebook() {
    var d = document;
    var s = 'script';
    var id = 'facebook-jssdk';
    var js, fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) return;
    js = d.createElement(s); js.id = id;
    js.src = "//connect.facebook.net/en_US/all.js#xfbml=1&appId=209177899211727";
    fjs.parentNode.insertBefore(js, fjs);
  }
});

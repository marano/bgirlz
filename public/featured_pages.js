$(function () {
  var height = $('meta[name=featured-pages-height]').attr('content');
  var color = $('meta[name=featured-pages-color]').attr('content');
  if (!height) {
    height = '600px';
  } else {
    height = parseInt(height.replace('px', '') - 120) + 'px';
  }

  $('#slide').css('height', height);
  if (color) {
    $('#featured-pages').css('color', color);
  }

  $('#slide').carousel();
  $('#slide').carousel('pause');

  $('#slide').on('slide', function () {
    $('#student-name').animate({opacity: '0'}, 200);
  });

  $('#slide').on('slid', function () {
    var name = $('.carousel-inner .active').data('page-name');
    var link = $('.carousel-inner .active').data('page-original-link');
    $('#student-name h4').find('span').text(name);
    $('.fb-like').hide();
    $('.fb-like[data-href="' + link + '"]').show();
    if(!$('#student-name').is(':visible')) {
      $('#student-name').show();
    }
    $('#student-name').animate({opacity: '1'}, 200);
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
    var newheight = $(iframe).parent().parent().height();
    var newwidth = $(iframe).parent().parent().width();

    iframe.height = (newheight) + "px";
    iframe.width = (newwidth) + "px";
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

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

  function getParentLink(element) {
    if (element.tagName == 'A') {
      return $(element);
    } else {
      return getParentLink(element.parentElement);
    }
  }

});

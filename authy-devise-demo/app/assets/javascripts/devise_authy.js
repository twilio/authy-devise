$(document).ready(function() {
  $('a#authy-request-sms-link').unbind('ajax:success');
  $('a#authy-request-sms-link').bind('ajax:success', function(evt, data, status, xhr) {
    alert(data.message);
  });
});


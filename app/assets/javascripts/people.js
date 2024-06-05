$(document).on('click', 'form .remove_fields', function(event) {
  $(this).prev('input[type=hidden]').val('1');
  $(this).closest('fieldset').hide();
  event.preventDefault();
});

$(document).on('click', 'form .add_fields', function(event) {
  var time = new Date().getTime();
  var regexp = new RegExp($(this).data('id'), 'g');
  $(this).before($(this).data('fields').replace(regexp, time));
  event.preventDefault();
});


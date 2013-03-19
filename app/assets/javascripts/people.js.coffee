jQuery ->
  jQuery('form').on 'click', '.remove_fields', (event) ->
    jQuery(this).prev('input[type=hidden]').val('1')
    jQuery(this).closest('fieldset').hide()
    event.preventDefault()

    jQuery('form').on 'click', '.add_fields', (event) ->
      time = new Date().getTime()
      regexp = new RegExp(jQuery(this).data('id'), 'g')
      jQuery(this).before(jQuery(this).data('fields').replace(regexp, time))
      event.preventDefault()

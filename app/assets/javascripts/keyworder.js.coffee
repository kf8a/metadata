$ ->
  default_text = 'Search for core areas, keywords or people'

  $('#keyworder').focus ->
    if @.value == default_text
      @.value = ''

  $('#keyworder').blur ->
    if @.value == ''
      @.value = default_text

  $('#keyworder').autocomplete
    source: '/datatables/suggest'
    minLength: 2


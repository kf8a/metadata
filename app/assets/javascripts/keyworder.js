jQuery(function() {
  const default_text = 'Search for core areas, keywords or people';

  $('#keyworder').focus(function() {
    if (this.value === default_text) {
      return this.value = '';
    }
  });

  return $('#keyworder').autocomplete({
    source: '/datatables/suggest',
    minLength: 2
  });
});

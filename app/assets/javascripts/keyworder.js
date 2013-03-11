	if (jQuery('#keyworder').length > 0) {
jQuery(function() {
	jQuery.ajax({
		url: "/datatables/suggest",
		dataType: "json",
		success: function(data) {
			var cache = data;
	
			jQuery("#keyworder").autocomplete({
				source: cache,
				minLength: 2
			});
		}
	});
});
			
jQuery(function() {

		if (jQuery('#keyworder')[0].value == 'Search for core areas, keywords or people') {	
			jQuery('#keyworder').addClass("default");
		};

});

	
jQuery('#keyworder').focus(function() {
	if(this.value=='Search for core areas, keywords or people') {
			this.value='';
			jQuery(this).removeClass('default');
	}	});
jQuery('#keyworder').blur(function() {
	if(this.value=='') {
			this.value='Search for core areas, keywords or people';
			jQuery(this).addClass('default');			
	} });
	};
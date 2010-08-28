jQuery(document).ready(function() { 
	function geo_decode() {
		var email  = jQuery('#email').get(0);
		if ((email != undefined)) {
			email_name = email.innerHTML.split(/ /)[0]
			email_domain = email.innerHTML.split(/ /)[2]
			email = [email_name, email_domain].join('@');

			jQuery('#email').empty();
			jQuery('#email').append("<a id='email' href='mailto:"+email+"'>"+email+"</a>");
		}
	};

	// truncate long contexts on datatable pages
	jQuery('.truncate').truncate({max_length: 500});

	geo_decode();

	jQuery('.quickTree').quickTree();
	jQuery('.collapsable').collapseDiv();

	jQuery('.quickTree').prepend("<a href='#' class='expand_all'>[Expand All]</a>")
	jQuery('.expand_all').toggle(
		function() {
			jQuery('span.expand:not(.contract)').trigger('click');
			jQuery(this).text('[Collapse All]');
		},
		function() {
			jQuery('span.expand.contract').trigger('click');
			jQuery(this).text('[Expand All]');
		});
	});
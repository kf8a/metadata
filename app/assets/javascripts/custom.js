jQuery(document).ready(function() {

	function geo_decode() {
		var email  = jQuery('.person-email').get(0);
		if ((email !== undefined)) {
			email_name = email.innerHTML.split(/ /)[0]
			email_domain = email.innerHTML.split(/ /)[2]
			email_string = [email_name, email_domain].join('@');

			//jQuery('#email').empty();
			jQuery(email).replaceWith("<a id='email' href='mailto:"+email_string+"'>"+email_string+"</a>");
		}
	}

	// truncate long contexts on datatable pages
	jQuery('.truncate').truncate({max_length: 800});

	geo_decode();

  // add post to permission controller
  jQuery('#permission-request').bind('click', function() {
    console.log(jQuery(this).data('datatableid'));
    jQuery.post('/permission_requests',
        {datatable: jQuery(this).data('datatableid')});
  });

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


    //This sends a delete request and hides the containing element
    jQuery('.deleter').live('click', function(e) {
        e.preventDefault();
        path = jQuery(this).attr('href');
        jQuery(this).parent().hide('slow');
        jQuery.ajax({
            type: 'DELETE',
            url: path
        });
    });

    // Make member-only content visible and adjust the sign-in indicator if necessary
    // append a random number so that IE7 will actually make the call and not return a cached value
    url = "/users?"
    jQuery.get(url.concat(Math.random()));

    //Uses tokens for authors
//    jQuery('#citation_author_block_input').tokenInput('/authors.json', { crossDomain: false });

});

function remove_fields(link) {
	jQuery(link).prev("input[type=hidden]").val("1");
	jQuery(link).parent().parent(".inputs").first().hide();
}

function add_fields(link, association, content) {
	var new_id = new Date().getTime();
	var regexp = new RegExp("new_" + association, "g")
		jQuery(link).prev().append(content.replace(regexp, new_id));
}

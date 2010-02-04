

jQuery(document).ready(function() { 
	function geo_decode() {
			var email  = jQuery('#email').get(0);
			if ((email != undefined)) {
				email = email.innerHTML.split(/ /).join('@');

				jQuery('#email').empty();
				jQuery('#email').append("<a id='email' href='mailto:"+email+"'>"+email+"</a>");
			}
	}
	
	geo_decode();
	jQuery('.quickTree').quickTree();
});

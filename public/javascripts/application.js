

$(document).ready(function() { 
	function geo_decode() {
			var email  = $('#email').get(0);
			if ((email != undefined)) {
				email = email.innerHTML.split(/ /).join('@');

				$('#email').empty();
				$('#email').append("<a id='email' href='mailto:"+email+"'>"+email+"</a>");
			}
	}
	
	geo_decode();
});

function geo_decode() {
		var email  = $('email');
		if (email != null) {
			email = email.innerHTML.gsub(/ at /,'@');
			$('email').replace("<a id='email' href='mailto:"+email+"'>"+email+"</a>");
		}
}

window.onload = function() { geo_decode()}
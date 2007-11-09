function geo_decode() {
	var email  = $('email').innerHTML;
	email = email.gsub(/ at /,'@');
	$('email').replace("<a id='email' href='mailto:"+email+"'>"+email+"</a>");
}

window.onload = function() { geo_decode()}
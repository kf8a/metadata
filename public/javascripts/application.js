jQuery(document).ready(function() {
	function geo_decode() {
		var email  = jQuery('.person-email').get(0);
		if ((email != undefined)) {
			email_name = email.innerHTML.split(/ /)[0]
			email_domain = email.innerHTML.split(/ /)[2]
			email_string = [email_name, email_domain].join('@');

			//jQuery('#email').empty();
			jQuery(email).replaceWith("<a id='email' href='mailto:"+email_string+"'>"+email_string+"</a>");
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

  jQuery('.area-graph').each(function() {
    var id = jQuery(this).attr('id');

    var current_div = this;
    jQuery.getJSON("/visualizations/" + id, function(json){jQuery
      var dateFormat = pv.Format.date("%Y-%m-%d %H:%M:%S");
      json.forEach(function(d) {d.datetime = dateFormat.parse(d.datetime)});
      var h = 260,
          w = 360,
          y = pv.Scale.linear(json, function(d) { return d.value}).range(0,h),
          x = pv.Scale.linear(json, function(d){ return d.datetime}).range(0,w);
      var vis = new pv.Panel()
      .canvas(current_div)
      .margin(40)
      .width(w)
      .height(h);

      vis.add(pv.Rule)
        .data(y.ticks())
        .strokeStyle("#eee")
        .bottom(y)
        .anchor("left").add(pv.Label).text(y.tickFormat);

      vis.add(pv.Rule)
        .data(x.ticks())
        .strokeStyle("#eee")
        .left(x)
        .anchor("bottom").add(pv.Label).text(x.tickFormat);

      vis.add(pv.Area)
        .data(json)
        .left(function(d) {return x(d.datetime) })
        .height(function(d) { return y(d.value) })
        .fillStyle("rgb(121,173,210)")
        .bottom(1);

      vis.root.render();
    });
  });

  jQuery('.bar-graph').each(function() {
    var id = jQuery(this).attr('id');

    var current_div = this;
    jQuery.getJSON("/visualizations/" + id, function(json){jQuery
      var dateFormat = pv.Format.date("%Y-%m-%d %H:%M:%S");
      json.forEach(function(d) {d.datetime = dateFormat.parse(d.datetime)});
      var h = 260,
          w = 360,
          y = pv.Scale.linear(json, function(d) { return d.value}).range(0,h),
          x = pv.Scale.linear(json, function(d){ return d.datetime}).range(0,w);
      var vis = new pv.Panel()
      .canvas(current_div)
      .margin(40)
      .width(w)
      .height(h);

      vis.add(pv.Rule)
        .data(y.ticks())
        .strokeStyle("#eee")
        .bottom(y)
        .anchor("left").add(pv.Label).text(y.tickFormat);

      vis.add(pv.Rule)
        .data(x.ticks())
        .strokeStyle("#eee")
        .left(x)
        .anchor("bottom").add(pv.Label).text(x.tickFormat);

      vis.add(pv.Panel)
      .add(pv.Bar)
      .data(json)
        .left(function(d) {return x(d.datetime) })
        .height(function(d) { return y(d.value) })
        .width(3)
        .bottom(0);

      vis.root.render();
    });
  });
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

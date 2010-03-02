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
	
	jQuery('.sortable_container').draggable({
		zIndex: 100000,
		revert: 'invalid',
		opacity: 0.5,
		scroll: true,
		helper: 'clone'
	});
	
	jQuery(".sortable_list").droppable({
			accept: ".sortable_container",
			drop: function(ev, ui) {
				var source_li = jQuery(ui.draggable);
				var child_ul = jQuery(this).children('ul');
				var message_id = source_li.children('input').val();
				var parent_id = 0;
				if(same_parent(source_li, child_ul)){
					return;
				}
				insert_alphabetic(child_ul, source_li);
				update_parent(message_id, parent_id);
	    }
		});
		
	jQuery(".sortable_container").droppable({
		accept: ".sortable_container",
		hoverClass: 'sortable_container-hover',
		tolerance : 'pointer',
		greedy : true,
		drop: function(ev, ui) {
			var source_li = jQuery(ui.draggable);
			var target_li = jQuery(this).children('ul');
			var set_id = source_li.children('input').value;
			console.log(source_li.text());
			console.log(source_li.html());
			var parent_id = target_li.children('li').children('input').val();
			if(target_li.children('ul').length <= 0){
				target_li.append('<ul></ul>');
			}
			var child_ul = target_li;
			if(same_parent(source_li, child_ul)){
				return;
			}
			jQuery(this).children('ul:hidden').slideDown();
			insert_alphabetic(child_ul, source_li);
			update_parent(set_id, parent_id);
		}
	});

	function same_parent(source_li, child_ul){
		return source_li.parent() == child_ul;
	}	
	
	function insert_alphabetic(child_ul, source_li){
		var kids = child_ul.children('li');
		var source_text = source_li.text().toLowerCase();
		for(i=0; i<kids.length; i++){
			var current_text = jQuery(kids[i]).text().toLowerCase();
			if(source_text < current_text){
				source_li.insertBefore(kids[i]);
				return;
			}
		}
		source_li.appendTo(child_ul);
	}
 
	function update_parent(set_id, parent_id){

		var path = jQuery('#update_path').val();
		console.log(path);
		jQuery.post(path + '/' + set_id + '.js', {parent_id: parent_id, action: 'update', _method: 'put', only_parent: 'true' },
		  function(data){
				if(data.length > 0){
					var result = eval('(' + data + ')');
					if(!result.success){
						jQuery.jGrowl.error(result.message);
					}
				}
		  });
		return false;
	}
	
	
	geo_decode();
	jQuery('.quickTree').quickTree();
	jQuery('.collapsable').collapseDiv();
	jQuery('#keyworder').addClass("default");
	
	jQuery('#keyworder').focus(function() {
		if(this.value==jQuery(this)[0].defaultValue) {
				this.value='';
		};
		jQuery(this).removeClass('default');
	});
	jQuery('#keyworder').blur(function() {
		if(this.value=='') {
				this.value=jQuery(this)[0].defaultValue;
		};
		jQuery(this).addClass('default');
	});
	
	jQuery('#peoplesearch').addClass("default");
	
	jQuery('#peoplesearch').focus(function() {
		if(this.value==jQuery(this)[0].defaultValue) {
				this.value='';
		};
		jQuery(this).removeClass('default');
	});
	jQuery('#peoplesearch').blur(function() {
		if(this.value=='') {
				this.value=jQuery(this)[0].defaultValue;
		};
		jQuery(this).addClass('default');
	});
	
	
	jQuery('.quickTree').prepend("<a href='#' class='expand_all'>[Expand All]</a>")
	jQuery('.expand_all').toggle(
		function() {
			jQuery('span.expand').trigger('click');
			jQuery(this).text('[Collapse All]');
	},
		function() {
			jQuery('span.expand').tigger('click');
			jQuery(this).text('[Expand All]');
		});
});

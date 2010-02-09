jQuery(document).ready(function() { 
	function geo_decode() {
			var email  = jQuery('#email').get(0);
			if ((email != undefined)) {
				email = email.innerHTML.split(/ /).join('@');

				jQuery('#email').empty();
				jQuery('#email').append("<a id='email' href='mailto:"+email+"'>"+email+"</a>");
			}
	};
	
	jQuery('.theme_container').draggable({
		zIndex: 100000,
		revert: 'invalid',
		opacity: 0.5,
		scroll: true,
		helper: 'clone'
	});
	
	jQuery(".theme_list").droppable({
			accept: ".theme_container",
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
		
	jQuery(".theme_container").droppable({
		accept: ".theme_container",
		hoverClass: 'theme_container-hover',
		tolerance : 'pointer',
		greedy : true,
		drop: function(ev, ui) {
			var source_li = jQuery(ui.draggable);
			var target_li = jQuery(this).children('ul');
			console.log(target_li);
			console.log(target_li.children('li'));
			var theme_id = source_li.children('input').value;
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
			update_parent(theme_id, parent_id);
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
 
	function update_parent(theme_id, parent_id){

		var path = jQuery('#update_path').val();
		jQuery.post(path + '/' + theme_id + '.js', {parent_id: parent_id, action: 'update', _method: 'put', only_parent: 'true' },
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
});

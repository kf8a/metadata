/*
quickTree 0.4 - Simple jQuery plugin to create tree-structure navigation from an unordered list
http://scottdarby.com/

Copyright (c) 2009 Scott Darby

Dual licensed under the MIT and GPL licenses:
http://www.opensource.org/licenses/mit-license.php
http://www.gnu.org/licenses/gpl.html
*/

jQuery.fn.collapseDiv = function() {
	return this.each(function(){
		var jQueryCollapse = jQuery(this);
		var jQueryroots = jQueryCollapse.find('div');
		
		jQueryCollapse.addClass('my-collapse');
		jQueryCollapse.find('div').hide();
		
		jQueryCollapse.find('h2').prepend('<span class="expand" />');
		jQueryCollapse.addClass('expanded');
			
		jQuery('span.expand').toggle(
			function(){
				jQuery(this).toggleClass('contract').parent().next('div').slideDown();
				jQuery(this).parent().toggleClass('expanded');
			},
			function(){
					jQuery(this).toggleClass('contract').parent().next('div').slideUp();
					jQuery(this).parent().toggleClass('expanded');
			});
	});
};

jQuery.fn.quickTree = function() {
	return this.each(function(){

		//set variables
		var jQuerytree = jQuery(this);
		var jQueryroots = jQuerytree.find('li');

		//set last list-item as variable (to allow different background graphic to be applied)
		//jQuerytree.find('li:last-child').addClass('last');

		//add class to allow styling
		jQuerytree.addClass('tree');

		//hide all lists inside of main list by default
		jQuerytree.find('ul').hide();

		//iterate through all list items
		jQueryroots.each(function(){
			//if list-item contains a child list
			if (jQuery(this).children('ul').length > 0) {
				//add expand/contract control
				
				jQuery(this).addClass('root').contents(':first').wrap('<span class="expand" />');
				jQuery(this).parent().addClass('expanded');
			}
			}); //end .each

		//handle clicking on expand/contract control
		jQuery('span.expand').toggle(
			function(){
				jQuery(this).toggleClass('contract').nextAll('ul').slideDown();
				jQuery(this).parent().toggleClass('expanded');
			},
			function(){
				jQuery(this).toggleClass('contract').nextAll('ul').slideUp();
				jQuery(this).parent().toggleClass('expanded');
			}   
		);

		// jQuery.find('#quickTree-expand').toggle(
		// 	function() {
		// 		jQuery.find.('span.expand').toggle();
		// 	},
		// 	function() {
		// 		jQuery.find.('span.expand').toggle();
		// 	})
		//jQuery('span.expand').toggleClass('contract').nextAll('ul').slideDown();
	});
};

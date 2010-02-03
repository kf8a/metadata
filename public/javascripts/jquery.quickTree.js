/*
quickTree 0.4 - Simple jQuery plugin to create tree-structure navigation from an unordered list
http://scottdarby.com/

Copyright (c) 2009 Scott Darby

Dual licensed under the MIT and GPL licenses:
http://www.opensource.org/licenses/mit-license.php
http://www.gnu.org/licenses/gpl.html
*/
jQuery.fn.quickTree = function() {
    return this.each(function(){
	
		//set variables
        var $tree = $(this);
        var $roots = $tree.find('li');
        
		//set last list-item as variable (to allow different background graphic to be applied)
        $tree.find('li:last-child').addClass('last');
		
		//add class to allow styling
        $tree.addClass('tree');
		
		//hide all lists inside of main list by default
        $tree.find('ul').hide();
		
		//iterate through all list items
        $roots.each(function(){
		
			//if list-item contains a child list
            if ($(this).children('ul').length > 0) {
			
				//add expand/contract control
                $(this).addClass('root').prepend('<span class="expand" />');
				
            }
            
        }); //end .each

		//handle clicking on expand/contract control
        $('span.expand').toggle(
			//if it's clicked once, find all child lists and expand
            function(){
                $(this).toggleClass('contract').nextAll('ul').slideDown();
            },
			//if it's clicked again, find all child lists and contract
            function(){
                $(this).toggleClass('contract').nextAll('ul').slideUp();
            }
        );
    });
};
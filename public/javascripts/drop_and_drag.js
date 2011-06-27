/* DO NOT MODIFY. This file was compiled Mon, 27 Jun 2011 01:58:52 GMT from
 * /home/jon/Programming/Rails/metadata/app/coffeescripts/drop_and_drag.coffee
 */

(function() {
  jQuery(document).ready(function() {
    var handleDrop, sortedDrop;
    sortedDrop = function(event, ui) {
      var controller_name, dragged, dragged_id, dropTarget, target_id;
      dragged = ui.draggable;
      dragged_id = dragged.attr('id');
      controller_name = dragged.attr('controller_name');
      dropTarget = jQuery(this).parent().find('span[draggable=true]');
      target_id = dropTarget.attr('id');
      return jQuery.post('/' + controller_name + '/' + dragged_id + '/move_before/' + target_id, function(data) {
        var original;
        original = jQuery(dropTarget).parent().parent().parent();
        original.empty();
        original.before(data);
        jQuery(dragged).parent().fadeOut();
        jQuery(dragged).parent().remove();
        jQuery(original).prev().find('span[draggable=true]').draggable({
          revert: 'invalid'
        });
        jQuery(original).prev().find('span[draggable=true]').droppable({
          hoverClass: 'hovered',
          drop: handleDrop
        });
        jQuery('div.droppable').droppable({
          hoverClass: 'hovered',
          drop: sortedDrop
        });
        original.fadeOut();
        return original.remove();
      });
    };
    handleDrop = function(event, ui) {
      var controller_name, dragged, dragged_id, dropTarget, target_id;
      dragged = ui.draggable;
      dragged_id = dragged.attr('id');
      controller_name = dragged.attr('controller_name');
      dropTarget = this;
      target_id = this.id;
      return jQuery.post('/' + controller_name + '/' + dragged_id + '/move_to/' + target_id, function(data) {
        var original;
        original = jQuery(dropTarget).parent();
        original.empty();
        original.before(data);
        jQuery(dragged).parent().fadeOut();
        jQuery(dragged).parent().remove();
        jQuery(original).prev().find('span[draggable=true]').draggable({
          revert: 'invalid'
        });
        jQuery(original).prev().find('span[draggable=true]').droppable({
          hoverClass: 'hovered',
          drop: handleDrop
        });
        jQuery('div.droppable').droppable({
          hoverClass: 'hovered',
          drop: sortedDrop
        });
        original.fadeOut();
        return original.remove();
      });
    };
    jQuery('span[draggable=true]').draggable({
      revert: 'invalid'
    });
    jQuery('span[draggable=true]').droppable({
      hoverClass: 'hovered',
      drop: handleDrop
    });
    return jQuery('div.droppable').droppable({
      hoverClass: 'hovered',
      drop: sortedDrop
    });
  });
}).call(this);

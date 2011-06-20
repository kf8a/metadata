jQuery(document).ready ->

  sortedDrop = (event, ui) ->
    dragged = ui.draggable
    dragged_id = dragged.attr('id')
    dropTarget = jQuery(this).parent().find('span[draggable=true]')
    target_id = dropTarget.attr('id')

    jQuery.post('/themes/' + dragged_id + '/move_before/' + target_id, (data) ->
      original = jQuery(dropTarget).parent().parent().parent()
      original.empty()
      original.before(data)

      jQuery(dragged).parent().fadeOut()
      jQuery(dragged).parent().remove()
      jQuery(original).prev().find('span[draggable=true]').draggable revert: 'invalid'
      jQuery(original).prev().find('span[draggable=true]').droppable hoverClass: 'hovered', drop: handleDrop
      jQuery('div.droppable').droppable hoverClass: 'hovered', drop: sortedDrop

      original.fadeOut()
      original.remove()
    )

  handleDrop = (event, ui) ->
    dragged = ui.draggable
    dragged_id = dragged.attr('id')
    dropTarget = this
    target_id = this.id

    jQuery.post('/themes/' + dragged_id + '/move_to/' + target_id, (data) ->
      original = jQuery(dropTarget).parent()
      original.empty()
      original.before(data)

      jQuery(dragged).parent().fadeOut()
      jQuery(dragged).parent().remove()
      jQuery(original).prev().find('span[draggable=true]').draggable revert: 'invalid'
      jQuery(original).prev().find('span[draggable=true]').droppable hoverClass: 'hovered', drop: handleDrop
      jQuery('div.droppable').droppable hoverClass: 'hovered', drop: sortedDrop
      original.fadeOut()
      original.remove()
    )

  jQuery('span[draggable=true]').draggable revert: 'invalid'
  jQuery('span[draggable=true]').droppable hoverClass: 'hovered', drop: handleDrop
  jQuery('div.droppable').droppable hoverClass: 'hovered', drop: sortedDrop

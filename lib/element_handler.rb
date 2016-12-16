# Handle elememnts when parsing eml documents
class ElementHandler
  def apply(element)
    element.each { |node| handle(node) } if element
  end

  def handle(node)
    if node.is_a? REXML::Text
      handle_text_node(node)
    elsif node.is_a? REXML::Element
      handle_element node
    else
      return # ignore comments and processing instructions
    end
  end

  def handle_element(element)
    handler_method = 'handle_' + element.name.tr('-', '_')
    if respond_to? handler_method
      send(handler_method, element)
    else
      default_handler(element)
    end
  end

  def default_handler(element)
    handle element
  end

  def handle_text_mode(text_mode)
    text_mode.value
  end
end

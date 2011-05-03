class ElementHandler
  
  def apply element
    element.each { |node| handle(node)} if element
  end

  def handle node
    if node.kind_of? REXML::Text
      handleTextNode(node)
    elsif node.kind_of? REXML::Element
      handle_element node
    else
      return #ignore comments and processing instructions
    end
  end
  
  def handle_element element
    handler_method = "handle_" + element.name.tr("-","_")
    if self.respond_to? handler_method
      self.send(handler_method, element)
    else
      default_handler(element)
    end
  end

  def default_handler element
    handle element
  end
  
  def handleTextNode textNode
    textNode.value
  end
end

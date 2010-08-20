class DocumentNode < Treetop::Runtime::SyntaxNode
  def content()
    elements.map do |e|
      e.content
    end
  end
end

class CitationNode < Treetop::Runtime::SyntaxNode
  def content(h=Citation.new)
    elements.map do |e| 
      e.content(h)
    end
  end
end

class ParentNode < Treetop::Runtime::SyntaxNode
  def content(h)
    elements.each do |e| 
      e.content(h)
    end
    h
  end
end


class TagNode < Treetop::Runtime::SyntaxNode

  def initialize(input, interval, elements)
    super(input, interval, elements)
    @name = ''
  end
  
  def content(h)
#    h[@name] = text_value[6..text_value.length].gsub("\r\n",' ').gsub("\n",' ')
  end
end


class CitationType < Treetop::Runtime::SyntaxNode
  def content(h)
    #h['type'] = text_value[6..text_value.length].chomp
  end
end

class Tags < Treetop::Runtime::SyntaxNode
  def content(h)
    p text_value[0..2]
  end
end

class NullNode < Treetop::Runtime::SyntaxNode
  def content(h={})
  end
end

class TextNode < Treetop::Runtime::SyntaxNode
  def content(h)
    #h[text_value[0..2]] = text_value[6..text_value.length].join(' ').chomp
  end
end

class Abstract < Treetop::Runtime::SyntaxNode
  def content(h)
    h.abstract = text_value[6..text_value.length].gsub("\r\n",' ').gsub("\n",' ')
  end
end

class AuthorNode < Treetop::Runtime::SyntaxNode
  def content(h)
    sur_name, given_name = text_value.chomp.split(',')
    a = Author.new(:sur_name => sur_name, :given_name => given_name)
    h.authors << a
  end
end

class TitleNode < Treetop::Runtime::SyntaxNode
  def content(h)
    if text_value[0..2] == 'T1' then 
      h.title = text_value[6..text_value.length].gsub("\r\n",' ').gsub("\n",' ')
    else
      if h.title.nil?
        h.title = text_value[6..text_value.length].gsub("\r\n",' ').gsub("\n",' ')
      end
    end
  end
end

class Keyword < TagNode
  def content(h)
    #h.keywords = text_value[6..text_value.length]
  end
end

class PageTag < Treetop::Runtime::SyntaxNode
  def content(h)
    start_page, end_page = text_value[6..text_value.length].chomp
    h.start_page_number = start_page
    h.ending_page_number = end_page if end_page
  end
end

def extract_value(value)
  text_value[6..text_value.length].chomp
end

class ParentNode < Treetop::Runtime::SyntaxNode
  def content(basename, h)
    elements.each do |e| 
      e.content(basename, h)
    end
    h
  end
end

class TextNode < Treetop::Runtime::SyntaxNode
  def content(basename, h)
    extract_value(text_value)
  end
end

class NullNode < Treetop::Runtime::SyntaxNode
  def content(basename, h)
  end
end


class AuthorNode < Treetop::Runtime::SyntaxNode
  def content(basename, h)
    sur_name, given_name = extract_value(text_value).chomp.split(',')
    a = Author.new(:sur_name => sur_name.strip, :given_name => given_name.strip, :seniority => h.authors.size )
    h.authors << a
  end
end

class TitleNode < Treetop::Runtime::SyntaxNode
  def content(basename, h)
    if text_value[0..2] == 'T1' then 
      h.title = extract_value(text_value).gsub("\r\n",' ').gsub("\n",' ')
    else
      if h.title.nil?
        h.title = extract_value(text_value).gsub("\r\n",' ').gsub("\n",' ')
      end
    end
  end
end

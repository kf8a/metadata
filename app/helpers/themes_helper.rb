module ThemesHelper
  def render_themes(theme, &block)
    concat('
  <li id="theme_' + theme.id.to_s + '" class="theme_container delete-container"> 
     <input type="hidden" value=' + theme.id.to_s + ' >', block.binding)
    yield(theme)
    concat('
  <ul id="ul_' + theme.id.to_s + '">', block.binding)
#    if !theme.leaf?
      theme.children.each do |child|
        render_themes(child, &block)
      end
#    end
    concat('</li>
  </ul>

  ', block.binding)
  end

end

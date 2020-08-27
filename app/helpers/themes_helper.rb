# frozen_string_literal: true

# Help to render theme containers
module ThemesHelper
  def render_themes(theme, &block)
    theme_id = theme.id.to_s
    concat('
  <li id="theme_' + theme_id + '" class="theme_container delete-container">
     <input type="hidden" value=' + theme_id + ' >', block.binding)
    yield(theme)
    concat('
  <ul id="ul_' + theme_id + '">', block.binding)
    # if !theme.leaf?
    theme.children.each do |child|
      render_themes(child, &block)
    end
    # end
    concat('</li>
  </ul>

  ', block.binding)
  end
end

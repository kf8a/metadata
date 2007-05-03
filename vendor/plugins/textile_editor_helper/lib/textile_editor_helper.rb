module TextileEditorHelper
  # creates a text_area for the given object/field pair
  # and keeps track of the ID used (necessary for textile_editor_initialize)
  def textile_editor(object, field, options={})
    editor_id = options[:id] || '%s_%s' % [object, field]
    mode      = options.delete(:simple) ? 'simple' : 'extended'
    (@textile_editor_ids ||= []) << [editor_id, mode]
    text_area(object, field, options)
  end
  
  # adds the necessary javascript include tags, stylesheet tags,
  # and load event with necessary javascript to active textile editor(s)
  # sample output:
  #    <link href="/stylesheets/button_styles.css" media="screen" rel="Stylesheet" type="text/css" />
  #    <link href="/stylesheets/editor_styles.css" media="screen" rel="Stylesheet" type="text/css" />
  #    <script src="/javascripts/text-tags.js" type="text/javascript"></script>
  #    <script type="text/javascript">
  #    Event.observe(window, 'load', function() {
  #    edToolbar('article_body', 'extended');
  #    edToolbar('article_body_excerpt', 'simple');
  #    });
  #    </script>  
  def textile_editor_initialize(*dom_ids)
    editor_ids = (@textile_editor_ids || []) + textile_extract_dom_ids(*dom_ids)
    output = []
    output << stylesheet_link_tag('textile-editor')
    output << javascript_include_tag('textile-editor')
    output << '<script type="text/javascript">'
    output << %{Event.observe(window, 'load', function() \{}
    editor_ids.each do |editor_id, mode|
      output << "edToolbar('%s', '%s');" % [editor_id, mode || 'extended']
    end
    output << '});'
    output << '</script>'
    output.join("\n")
    
  end

  def textile_extract_dom_ids(*dom_ids)
    hash = dom_ids.last.is_a?(Hash) ? dom_ids.pop : {}

    hash.inject(dom_ids) do |ids, (object, fields)|
      ids + Array(fields).map { |field| "%s_%s" % [object, field] }
    end
  end
end
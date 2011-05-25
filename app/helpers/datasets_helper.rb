module DatasetsHelper
  def keyword_field_with_auto_complete_tag(object, tag_options = {}, completion_options = {})
    (completion_options[:skip_style] ? "" : auto_complete_stylesheet) +
    text_field_tag(object, @keyword_list ,tag_options) +
    content_tag("div", "", :id => "#{object}_auto_complete", :class => "auto_complete") +
    auto_complete_field("#{object}", { :url => { :action => "auto_complete_for_#{object}" } }.update(completion_options))
  end
end

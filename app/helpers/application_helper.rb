# Methods added to this helper will be available to all templates in the application.
require 'redcloth'

module ApplicationHelper
  def textilize(text)
    raw(RedCloth.new(text.to_s).to_html)
  end

  # use to strip out html tags when using truncate
  def strip_html_tags(string = '')
    string.gsub(/<\/?[^>]*>/,  "")
  end

  def lter_roles
    Role.find_all_by_role_type_id(RoleType.find_by_name('lter'))
  end

  def admin?
    current_user.try(:role) == 'admin'
  end

  def get_liquid_template(domain, controller, page)
    website = Website.find_by_name(domain)
    website = Website.first unless website
    plate = nil
    plate = website.layout(controller, page) if website
  end

  def link_to_remove_fields(name, f)
      f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end

  def link_to_add_fields(name, f, association)
      new_object = f.object.class.reflect_on_association(association).klass.new
        fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
              render(association.to_s.singularize + "_fields", :f => builder)
                end
          link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
  end

end

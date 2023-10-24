# frozen_string_literal: true

# Methods added to this helper will be available to all templates in the application.
require 'commonmarker'

module ApplicationHelper

  def markdown_to_html(text)
    raw(CommonMarker.render_html(text, :UNSAFE))
  end

  # use to strip out html tags when using truncate
  def strip_html_tags(string = '')
    string.gsub(/<\/?[^>]*>/,  '')
  end

  def lter_roles
    # TODO: this is both here and in the person controller
    # Role.where(role_type_id: RoleType.where(name: 'lter').first)
    roles = Role.where('role_type_id = 2 or role_type_id = 4')
    roles.map { |x| [augment_name(x.name[0..30], x.role_type_id), x.id] }
  end

  def admin?
    current_user.try(:role) == 'admin'
  end

  def current_controller?(controller)
    if controller_name == controller
      'current-nav'
    else
      'not-current-nav'
    end
  end

  # TODO: do remove in favor of unobtrusive javascript
  def link_to_remove_fields(name, form)
    form.hidden_field(:_destroy) + link_to_function(name, 'remove_fields(this)')
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder)
    end
    link_to(name, '#', class: 'add_fields', data: { id: id, fields: fields.delete("\n") })
  end

  # TODO: do remove in favor of unobtrusive javascript
  def link_to_function(name, *args, &block)
    html_options = args.extract_options!.symbolize_keys

    function = block_given? ? update_page(&block) : args[0] || ''
    onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
    href = html_options[:href] || '#'

    content_tag(:a, name, html_options.merge(href: href, onclick: onclick))
  end

  private

  def augment_name(name, role_type_id)
    return name if role_type_id != 4

    name + ' - lno role'
  end
end

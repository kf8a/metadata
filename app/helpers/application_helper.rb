# frozen_string_literal: true

# Methods added to this helper will be available to all templates in the application.
require 'commonmarker'

module ApplicationHelper
  def markdown_to_html(text)
    return nil if text.blank?

    raw(Commonmarker.to_html(text, options: { render: { unsafe: true } }))
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

  # Marks a nested record for deletion and hides its fields (nested-fields Stimulus controller)
  def link_to_remove_fields(name, form)
    form.hidden_field(:_destroy) +
      link_to(name, '#', data: { controller: 'nested-fields', action: 'nested-fields#remove' })
  end

  # Appends fields for a new nested record to the container (nested-fields Stimulus controller)
  def link_to_add_fields(name, form, association, container: "##{association}")
    new_object = form.object.send(association).klass.new
    placeholder = new_object.object_id.to_s
    fields = form.fields_for(association, new_object, child_index: placeholder) do |builder|
      render("#{association.to_s.singularize}_fields", f: builder)
    end
    link_to(name, '#', data: { controller: 'nested-fields', action: 'nested-fields#add',
                               nested_fields_template_value: fields,
                               nested_fields_placeholder_value: placeholder,
                               nested_fields_container_value: container })
  end

  private

  def augment_name(name, role_type_id)
    return name if role_type_id != 4

    name + ' - lno role'
  end
end

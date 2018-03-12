# frozen_string_literal: true

ThinkingSphinx::Index.define :citation, with: :active_record do
  indexes title
  indexes authors.sur_name, as: :authors, sortable: true
  indexes publication
  indexes pub_year, sortable: true
  has website_id
  set_property min_infix_len: 3
end

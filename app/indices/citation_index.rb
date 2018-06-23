# frozen_string_literal: true

ThinkingSphinx::Index.define :citation, with: :real_time do
  indexes title
  # indexes authors.sur_name, as: :authors, sortable: true, tye: :string
  indexes publication
  indexes pub_year, sortable: true
  has website_id
end

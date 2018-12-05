# frozen_string_literal: true

# ThinkingSphinx::Index.define :citation, with: :real_time do
#   indexes title, sortable: true, type: :string
#   indexes authors.sur_name, as: :authors, sortable: true, tye: :string
#   indexes publication, type: :string
#   indexes pub_year, sortable: true, type: :datetime
#   has website_id, type: :integer
# end

ThinkingSphinx::Index.define :citation, with: :active_record do
  indexes title, sortable: true
  indexes authors.sur_name, as: :all_author, sortable: true
  indexes publication
  indexes pub_year, sortable: true

  has website_id, type: :integer
end

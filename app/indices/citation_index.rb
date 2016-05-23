ThinkingSphinx::Index.define :citation, with: :active_record do
  indexes title
  indexes abstract
  indexes authors.sur_name, as: :authors, sortable: true
  indexes publication
  indexes pub_year, sortable: true
  has website_id
  set_property enable_star: 1
  set_property min_infix_len: 1
end

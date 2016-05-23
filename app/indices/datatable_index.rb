ThinkingSphinx::Index.define :datatable, with: :active_record do
  indexes title
  indexes description
  indexes theme.name, as: :theme
  indexes data_contributions.person.sur_name, as: :datatable_sur_name
  indexes data_contributions.person.given_name, as: :datatable_given_name
  indexes dataset.affiliations.person.sur_name, as: :sur_name
  indexes dataset.affiliations.person.given_name, as: :given_name
  indexes taggings.tag.name, as: :keyword_name
  indexes dataset.title, as: :dataset_title
  indexes dataset.dataset, as: :dataset_identifier
  indexes core_areas.name, as: :core_area
  indexes name
  has dataset.website_id, as: :website
  where 'datatables.on_web is true and datasets.on_web'

  # set_property field_weights: { keyword: 20, theme: 20, title: 10 }
end

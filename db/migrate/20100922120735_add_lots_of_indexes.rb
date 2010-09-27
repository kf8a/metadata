class AddLotsOfIndexes < ActiveRecord::Migration
  def self.up
    add_index :affiliations,            :person_id
    add_index :affiliations,            :role_id
    add_index :affiliations,            :dataset_id
    add_index :authors,                 :person_id
    add_index :authors,                 :citation_id
    add_index :citations,               :citation_type_id
    add_index :citations,               :website_id
    add_index :collections,             :datatable_id
    add_index :columns,                 :datatable_id
    add_index :columns,                 :variate_id
    add_index :datafiles,               :person_id
    add_index :datasets,                :project_id
    add_index :datasets,                :metacat_id
    add_index :datasets,                :sponsor_id
    add_index :datasets,                :website_id
    add_index :datasets_studies,        :dataset_id
    add_index :datasets_studies,        :study_id
    add_index :datasets_themes,         :theme_id
    add_index :datasets_themes,         :dataset_id
    add_index :datatables,              :dataset_id
    add_index :datatables,              :theme_id
    add_index :datatables,              :core_area_id
    add_index :datatables,              :study_id
    add_index :datatables_protocols,    :datatable_id
    add_index :datatables_protocols,    :protocol_id
    add_index :meeting_abstracts,       :meeting_id
    add_index :meetings,                :venue_type_id
    add_index :ownerships,              :datatable_id
    add_index :ownerships,              :user_id
    add_index :page_images,             :page_id
    add_index :permission_requests,     :datatable_id
    add_index :permission_requests,     :user_id
    add_index :permissions,             :user_id
    add_index :permissions,             :datatable_id
    add_index :permissions,             :owner_id
    add_index :protocols,               :person_id
    add_index :protocols,               :dataset_id
    add_index :protocols_sponsors,      :protocol_id
    add_index :protocols_sponsors,      :sponsor_id
    add_index :protocols_websites,      :protocol_id
    add_index :protocols_websites,      :website_id
    add_index :publications,            :publication_type_id
    add_index :publications,            :source_id
    add_index :publications,            :parent_id
    add_index :publications_treatments, :treatment_id
    add_index :publications_treatments, :publication_id
    add_index :roles,                   :role_type_id
    add_index :scribbles,               :person_id
    add_index :scribbles,               :protocol_id
    add_index :studies,                 :parent_id
    add_index :taggings,                :tagger_id
    add_index :templates,               :website_id
    add_index :themes,                  :parent_id
    add_index :treatments,              :study_id
    add_index :variates,                :datatable_id
    add_index :variates,                :unit_id
    add_index :variates,                :variate_theme_id
  end

  def self.down
    remove_index :affiliations,            :person_id
    remove_index :affiliations,            :role_id
    remove_index :affiliations,            :dataset_id
    remove_index :authors,                 :person_id
    remove_index :authors,                 :citation_id
    remove_index :citations,               :citation_type_id
    remove_index :citations,               :website_id
    remove_index :collections,             :datatable_id
    remove_index :columns,                 :datatable_id
    remove_index :columns,                 :variate_id
    remove_index :datafiles,               :person_id
    remove_index :datasets,                :project_id
    remove_index :datasets,                :metacat_id
    remove_index :datasets,                :sponsor_id
    remove_index :datasets,                :website_id
    remove_index :datasets_studies,        :dataset_id
    remove_index :datasets_studies,        :study_id
    remove_index :datasets_themes,         :theme_id
    remove_index :datasets_themes,         :dataset_id
    remove_index :datatables,              :dataset_id
    remove_index :datatables,              :theme_id
    remove_index :datatables,              :core_area_id
    remove_index :datatables,              :study_id
    remove_index :datatables_protocols,    :datatable_id
    remove_index :datatables_protocols,    :protocol_id
    remove_index :meeting_abstracts,       :meeting_id
    remove_index :meetings,                :venue_type_id
    remove_index :ownerships,              :datatable_id
    remove_index :ownerships,              :user_id
    remove_index :page_images,             :page_id
    remove_index :permission_requests,     :datatable_id
    remove_index :permission_requests,     :user_id
    remove_index :permissions,             :user_id
    remove_index :permissions,             :datatable_id
    remove_index :permissions,             :owner_id
    remove_index :plots,                   :treatment_id
    remove_index :plots,                   :study_id
    remove_index :protocols,               :person_id
    remove_index :protocols,               :dataset_id
    remove_index :protocols_sponsors,      :protocol_id
    remove_index :protocols_sponsors,      :sponsor_id
    remove_index :protocols_websites,      :protocol_id
    remove_index :protocols_websites,      :website_id
    remove_index :publications,            :publication_type_id
    remove_index :publications,            :source_id
    remove_index :publications,            :parent_id
    remove_index :publications_treatments, :treatment_id
    remove_index :publications_treatments, :publication_id
    remove_index :roles,                   :role_type_id
    remove_index :scribbles,               :person_id
    remove_index :scribbles,               :protocol_id
    remove_index :studies,                 :parent_id
    remove_index :taggings,                :tagger_id
    remove_index :templates,               :website_id
    remove_index :themes,                  :parent_id
    remove_index :treatments,              :study_id
    remove_index :variates,                :datatable_id
    remove_index :variates,                :unit_id
    remove_index :variates,                :variate_theme_id
  end
end
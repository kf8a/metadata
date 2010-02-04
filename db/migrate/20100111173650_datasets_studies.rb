class DatasetsStudies < ActiveRecord::Migration
  def self.up
    create_table :datasets_studies, :id => false do |t|
      t.integer :dataset_id
      t.integer :study_id
    end
    
    remove_column :datasets, :study_id
  end

  def self.down
    add_column :datasets, :study_id, :integer
    drop_table :datasets_studies
  end
end

class CreateSpecimens < ActiveRecord::Migration
  def self.up
    create_table :specimens do |t|
      t.integer :herbarium_id
      t.integer :accession_id
      t.string :collection
      t.string :template
      t.string :tribe
      t.string :family
      t.string :genus
      t.string :specific_epithet
      t.string :authority
      t.string :common_name
      t.string :habitat
      t.string :collector
      t.string :collectos_id
      t.string :collectors_number
      t.date :collection_date
      t.string :township_range_section
      t.text :site
      t.integer :n_sheets
      t.string :phenological_stage
      t.text :comments
      t.date :observation_date
      t.string :described_by
      t.string :entered_by
      t.date :entered_on
      t.boolean :qc_flag
      t.boolean :image_flag
      t.boolean :update_required
      t.string :_species
      t.string :_prev_family
      t.string :_prev_name
      t.float :latitude
      t.float :longitude
      t.float :geo_error_m
      
      t.string :species_code
      
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :specimens
  end
end

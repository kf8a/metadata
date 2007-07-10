class CreatePlots < ActiveRecord::Migration
  def self.up
    create_table :plots do |t|
      t.column :name, :string
      t.column :treatment_id, :integer
      t.column :replicate, :integer
      t.column :study_id, :integer
      t.column :description, :string
    end
  end

  def self.down
    drop_table :plots
  end
end

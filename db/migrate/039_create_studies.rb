class CreateStudies < ActiveRecord::Migration
  def self.up
    create_table :studies do |t|
      t.column :name, :string
    end
  end

  def self.down
    drop_table :studies
  end
end

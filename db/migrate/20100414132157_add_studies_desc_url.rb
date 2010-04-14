class AddStudiesDescUrl < ActiveRecord::Migration
  def self.up
    add_column :studies, :url, :string
  end

  def self.down
    remove_column :studies, :url
  end
end

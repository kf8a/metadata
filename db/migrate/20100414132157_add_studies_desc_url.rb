class AddStudiesDescUrl < ActiveRecord::Migration[4.2]
  def self.up
    add_column :studies, :url, :string
  end

  def self.down
    remove_column :studies, :url
  end
end

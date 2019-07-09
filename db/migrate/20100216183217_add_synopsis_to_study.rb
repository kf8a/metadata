class AddSynopsisToStudy < ActiveRecord::Migration[4.2]
  def self.up
    add_column :studies, :synopsis, :text
  end

  def self.down
    remove_column :studies, :synopsis
  end
end

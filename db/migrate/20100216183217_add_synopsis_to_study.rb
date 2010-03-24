class AddSynopsisToStudy < ActiveRecord::Migration
  def self.up
    add_column :studies, :synopsis, :text
  end

  def self.down
    remove_column :studies, :synopsis
  end
end

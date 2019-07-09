class DropUploadsTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :uploads
  end
end

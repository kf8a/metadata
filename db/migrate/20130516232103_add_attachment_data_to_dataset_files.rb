class AddAttachmentDataToDatasetFiles < ActiveRecord::Migration[4.2]
  def self.up
    change_table :dataset_files do |t|
      # t.attachment :data
    end
  end

  def self.down
    # drop_attached_file :dataset_files, :data
  end
end

class DatasetFile < ActiveRecord::Base
  belongs_to :dataset
  attr_accessible :name, :data

  if Rails.env.production?
    has_attached_file :data,
        :storage => :s3,
        :bucket => 'metadata_production',
        :path => "/dataset_files/:id.:extension",
        :s3_credentials => File.join(Rails.root, 'config', 's3.yml'),
        :s3_permissions => 'authenticated-read'
  else
    has_attached_file :data, :url => "/datasets/:id/download",
      :path => ":rails_root/uploads/datasets/:attachment/:id.:extension"
  end
end

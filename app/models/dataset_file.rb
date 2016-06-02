# A file associated with a dataset
class DatasetFile < ActiveRecord::Base
  belongs_to :dataset

  has_attached_file :data,
                    storage: :s3,
                    bucket: 'metadata_production',
                    path: '/dataset_files/:id.:extension',
                    s3_credentials: File.join(Rails.root, 'config', 's3.yml'),
                    s3_permissions: 'authenticated-read'
end

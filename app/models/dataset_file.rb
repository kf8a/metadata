# A file associated with a dataset
class DatasetFile < ApplicationRecord
  belongs_to :dataset

  has_attached_file :data,
                    storage: :s3,
                    bucket: 'metadata-production',
                    path: '/dataset_files/:id.:extension',
                    s3_host_name: 's3.us-east-1.amazonaws.com',
                    s3_credentials: Rails.root.join('config', 's3.yml'),
                    s3_region: 'us-east-1',
                    s3_permissions: 'authenticated-read',
                    validate_media_type: false

  do_not_validate_attachment_file_type :data

  def file_name
    data_file_name
  end
end

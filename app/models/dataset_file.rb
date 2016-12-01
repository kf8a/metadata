# A file associated with a dataset
class DatasetFile < ActiveRecord::Base
  belongs_to :dataset

  has_attached_file :data,
                    storage: :s3,
                    bucket: 'metadata-production',
                    path: '/dataset_files/:id.:extension',
                    s3_credentials: File.join(Rails.root, 'config', 's3.yml'),
                    s3_region: 'us-east-1',
                    s3_permissions: 'authenticated-read'

  do_not_validate_attachment_file_type :data

  def file_name
    data_file_name
  end
end

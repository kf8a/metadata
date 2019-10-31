# frozen_string_literal: true

# A meeting abstract
class Abstract < ApplicationRecord
  belongs_to :meeting_abstract_type
  belongs_to :meeting

  validates :meeting, presence: true

  self.table_name = 'meeting_abstracts'

  # has_attached_file :pdf,
  #                   storage: :s3,
  #                   bucket: 'metadata-production',
  #                   path: '/abstracts/pdfs/:id/:style/:basename.:extension',
  #                   s3_region: 'us-east-1',
  #                   s3_credentials: Rails.root.join('config', 's3.yml'),
  #                   s3_permissions: 'authenticated-read'

  has_one_attached :pdf

  # TODO: update validation for active storage
  # validates_attachment_content_type :pdf, content_type: /pdf/

  def self.by_authors
    order :authors
  end
end

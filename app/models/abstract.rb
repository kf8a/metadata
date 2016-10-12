# A meeting abstract
class Abstract < ActiveRecord::Base
  belongs_to :meeting_abstract_type
  belongs_to :meeting

  validates :meeting, presence: true

  self.table_name = 'meeting_abstracts'

  has_attached_file :pdf,
                    storage: :s3,
                    bucket: 'metadata-production',
                    path: '/abstracts/pdfs/:id/:style/:basename.:extension',
                    s3_credentials: File.join(Rails.root, 'config', 's3.yml'),
                    s3_permissions: 'authenticated-read'

  validates_attachment_content_type :pdf, content_type: /\pdf/
  before_post_process :transliterate_file_name

  def self.by_authors
    order :authors
  end

  def transliterate(str)
    str.tr('_', '-').tr(' ', '-')
  end

  def transliterate_file_name
    pdf.instance_write(:file_name, transliterate(pdf_file_name).to_s)
  end
end

# == Schema Information
#
# Table name: meeting_abstracts
#
#  id               :integer         not null, primary key
#  title            :text
#  authors          :text
#  abstract         :text
#  meeting_id       :integer
#  pdf_file_name    :string(255)
#  pdf_content_type :string(255)
#  pdf_file_size    :integer
#  pdf_updated_at   :datetime
#

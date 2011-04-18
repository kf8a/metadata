class Abstract < ActiveRecord::Base
  set_table_name 'meeting_abstracts'
  belongs_to :meeting
  
  validates_presence_of :meeting
  validates_presence_of :abstract


  if Rails.env.production?
    has_attached_file :pdf,
                      :storage => :s3,
                      :bucket => 'metadata_production',
                      :path => "/abstracts/pdfs/:id/:style/:basename.:extension",
                      :s3_credentials => File.join(Rails.root, 'config', 's3.yml'),
                      :s3_permissions => 'authenticated-read'
  else
    has_attached_file :pdf, :url => "/abstracts/:id/download",
        :path => ":rails_root/assets/abstracts/:attachment/:id/:style/:basename.:extension"
  end

  scope :by_authors, :order=> :authors
end

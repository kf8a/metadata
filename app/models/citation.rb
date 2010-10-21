class Citation < ActiveRecord::Base
  has_many :authors, :order => :seniority
  belongs_to :citation_type
  belongs_to :website
  
  has_attached_file :pdf, :url => "/assets/citations/:attachment/:id/:style/:basename.:extension",  
   :path => ":rails_root/assets/citations/:attachment/:id/:style/:basename.:extension"
  
  attr_protected :pdf_file_name, :pdf_content_type, :pdf_size

  scope :with_authors_by_sur_name_and_pub_year,
          :joins=> 'left join authors on authors.citation_id = citations.id',
          :conditions => 'seniority = 1',
          :order => 'authors.sur_name, pub_year desc'
   
end

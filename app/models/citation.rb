class Citation < ActiveRecord::Base
  include ActiveRecord::Transitions

  has_many :authors, :order => :seniority
  belongs_to :citation_type
  belongs_to :website

  accepts_nested_attributes_for :authors
  
  has_attached_file :pdf, :url => "/assets/citations/:attachment/:id/:style/:basename.:extension",  
   :path => ":rails_root/assets/citations/:attachment/:id/:style/:basename.:extension"
  
  attr_protected :pdf_file_name, :pdf_content_type, :pdf_size

  scope :with_authors_by_sur_name_and_pub_year,
          :joins=> 'left join authors on authors.citation_id = citations.id',
          :conditions => 'seniority = 1',
          :order => 'authors.sur_name, pub_year desc'
   
  state_machine do
    state :submitted
    state :accepted
    state :published

    event :accept do
      transitions :to => :accepted, :from => :submitted
    end
    event :publish do
      transitions :to => :published, :from => [:accepted, :submitted]
    end
  end
end

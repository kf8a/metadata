class Citation < ActiveRecord::Base
  has_many :authors
  belongs_to :citation_type
  belongs_to :website
  
  has_attached_file :pdf, :url => "/assets/citations/:attachment/:id/:style/:basename.:extension",  
   :path => ":rails_root/assets/citations/:attachment/:id/:style/:basename.:extension"
  
  attr_protected :pdf_file_name, :pdf_content_type, :pdf_size
  
  def formatted_as_default
    authors.collect {|author| "#{author.sur_name} #{author.given_name}"}.join(', ') + " <em> #{title.to_s}</em> #{pub_year.to_s}"
  end
 
end

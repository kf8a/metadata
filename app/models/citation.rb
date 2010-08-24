class Citation < ActiveRecord::Base
  has_many :authors
  belongs_to :citation_type
  belongs_to :website
  
  has_attached_file :pdf, :url => "/assets/citations/:attachment/:id/:style/:basename.:extension",  
   :path => ":rails_root/assets/citations/:attachment/:id/:style/:basename.:extension"
  
  def formatted_as_default
    authors.collect {|author| "#{author.sur_name} #{author.given_name}"}.join(', ') + title.to_s
  end
 
end

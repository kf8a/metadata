class Citation < ActiveRecord::Base
  has_many :authors
  belongs_to :citation_type
  belongs_to :website
  
  has_attached_file :pdf
  
  def to_s
    title.to_s
  end
end

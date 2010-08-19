class Citation < ActiveRecord::Base
  has_many :authors
  belongs_to :citation_type
  belongs_to :website
  
  def citation
    ""
  end
end

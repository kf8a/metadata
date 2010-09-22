class Unit < ActiveRecord::Base
  has_many :variates

  named_scope :not_in_eml, :conditions => ['in_eml is false']

  def human_name
    name.gsub(/Per/,'/').downcase
  end
  
end

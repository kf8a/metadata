class Unit < ActiveRecord::Base
  has_many :variates
  
  def human_name
    name.gsub(/Per/,'/').capitalize
  end
  
end

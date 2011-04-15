class Unit < ActiveRecord::Base
  has_many :variates

  after_find :update_job
  #  after_find :update_dictionary
  scope :not_in_eml, :conditions => ['in_eml is false']

  def human_name
    name.gsub(/Per/,'/').downcase
  end

  def update_job
    # Delayed::Job.enqueue UnitUpdateJob.new(self)
  end

 

  def update_dictionary
    # Delayed::Job.enqueue UnitDictionaryUpdateJob.new(self)
  end

end

#scenarios
# 1) we need a list of available units
#   Unit.all
#     return units on hand 
#     and then query in the background for more units

# 2) we need to retrieve a particular unit
#   Unit.find
#    


# == Schema Information
#
# Table name: units
#
#  id                     :integer         not null, primary key
#  name                   :string(255)
#  description            :text
#  in_eml                 :boolean         default(FALSE)
#  definition             :text
#  deprecated_in_favor_of :integer
#  unit_type              :string(255)
#  parent_si              :string(255)
#  multiplier_to_si       :float
#


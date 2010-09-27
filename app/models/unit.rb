class Unit < ActiveRecord::Base
  has_many :variates

  after_find :after_find
  #  after_find :update_dictionary
  named_scope :not_in_eml, :conditions => ['in_eml is false']

  def human_name
    name.gsub(/Per/,'/').downcase
  end

  def after_find
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


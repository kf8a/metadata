class StudyUrl < ActiveRecord::Base
  belongs_to :study
  belongs_to :website
  
end

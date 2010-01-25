class SpecimenImage < ActiveRecord::Base
  has_attached_file :image
  belongs_to :specimen
end

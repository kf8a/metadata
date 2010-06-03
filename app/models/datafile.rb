class Datafile < ActiveRecord::Base
  belongs_to :person
  has_attached_file :original_data
end

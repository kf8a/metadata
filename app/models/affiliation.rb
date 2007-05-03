class Affiliation < ActiveRecord::Base
  belongs_to :role
  belongs_to :person
  belongs_to :dataset
end

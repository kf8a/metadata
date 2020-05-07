class PersonProject < ApplicationRecord
  belongs_to :person
  belongs_to :project
  belongs_to :role
end

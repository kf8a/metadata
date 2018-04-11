# Data contributions link a person to a datatable
class DataContribution < ApplicationRecord
  belongs_to :person
  belongs_to :datatable
  belongs_to :role

  validates :role, presence: true
end

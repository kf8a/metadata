# Data contributions link a person to a datatable
class DataContribution < ActiveRecord::Base
  belongs_to :person
  belongs_to :datatable
  belongs_to :role

  validates :role, presence: true
end

# == Schema Information
#
# Table name: data_contributions
#
#  id           :integer         not null, primary key
#  person_id    :integer
#  datatable_id :integer
#  role_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#

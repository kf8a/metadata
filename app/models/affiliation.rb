class Affiliation < ActiveRecord::Base
  belongs_to :role
  belongs_to :person
  belongs_to :dataset
end


# == Schema Information
#
# Table name: affiliations
#
#  id         :integer         not null, primary key
#  person_id  :integer
#  role_id    :integer
#  dataset_id :integer
#  seniority  :integer
#  title      :string(255)
#


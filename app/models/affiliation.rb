# an affiliation links a person with a role and a dataset
class Affiliation < ActiveRecord::Base
  belongs_to :role
  belongs_to :person
  belongs_to :dataset

  def self.lter
    joins(:role).where('role_type_id = ?', RoleType.find_by(name: 'lter'))
  end

  def self.committees
    joins(:role)
      .where("roles.name like '%Committee%' or name like '%Network Representative%'")
      .order('seniority')
  end
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

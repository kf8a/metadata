# frozen_string_literal: true

# an affiliation links a person with a role and a dataset
class Affiliation < ApplicationRecord
  belongs_to :role
  belongs_to :person
  belongs_to :dataset, optional: true

  def self.current
    where(left_on < Time.zone.today)
  end

  def self.lter
    joins(:role).where('role_type_id = ?', RoleType.find_by(name: 'lter'))
  end

  def self.committees
    joins(:role)
      .where("roles.name like '%Committee%' or name like '%Network Representative%'")
      .order('seniority')
  end
end

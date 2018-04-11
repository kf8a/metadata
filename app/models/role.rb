# Roles link people and and affiliations
class Role < ApplicationRecord
  has_many :affiliations, dependent: :destroy
  has_many :people, through: :affiliations
  belongs_to :role_type

  def emeritus?
    name =~ /^Emeritus/
  end

  def committee?
    name =~ /Committee/ || name =~ /Network Representatives/
  end

  def self.data_roles
    where(role_type_id: RoleType.find_by(name: 'lter_dataset'))
  end

  def committee_role_name
    name.singularize if committee?
  end
end

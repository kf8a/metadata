# Roles link people and and affiliations
class Role < ActiveRecord::Base
  has_many :people, through: :affiliations
  has_many :affiliations
  belongs_to :role_type

  def emeritus?
    name =~ /^Emeritus/
  end

  def committee?
    name =~ /Committee/ || name =~ /Network Representatives/
  end

  def self.data_roles
    where(role_type_id: RoleType.find_by_name('lter_dataset'))
  end

  def committee_role_name
    name.singularize if committee?
  end
end

# == Schema Information
#
# Table name: roles
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  role_type_id       :integer
#  seniority          :integer
#  show_in_overview   :boolean         default(TRUE)
#  show_in_detailview :boolean         default(TRUE)
#

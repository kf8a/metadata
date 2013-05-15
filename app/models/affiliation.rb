class Affiliation < ActiveRecord::Base
  belongs_to :role
  belongs_to :person
  belongs_to :dataset

  def self.lter
    joins(:role).where('role_type_id = ?', RoleType.where(:name => 'lter').first)
  end

  def self.committees
    joins(:role).where(%q{roles.name like '%Committee%' or name like '%Network Representative%'})
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

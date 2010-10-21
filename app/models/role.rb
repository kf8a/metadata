class Role < ActiveRecord::Base
  has_many :people, :through => :affiliations
  has_many :affiliations
  belongs_to :role_type
  
  scope :data_roles, :conditions => ["role_type_id = ?", RoleType.find_by_name('lter_dataset')]

  def emeritus?
    name =~ /^Emeritus/
  end
  
  def committee?
    name =~ /Committee/ || name =~/Network Representatives/
  end
  
end

class Role < ActiveRecord::Base
  has_many :people, :through => :affiliations
  has_many :affiliations
  belongs_to :role_type
  
  def emeritus?
    name =~ /^Emeritus/
  end
end

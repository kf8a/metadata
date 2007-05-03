require 'csv'
require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'postgresql', 
  :host => 'localhost',
  :username => 'bohms',
  :database => 'meta_development'
)

class Role < ActiveRecord::Base
end  

class Affiliation < ActiveRecord::Base
  belongs_to :role
  belongs_to :person
  belongs_to :dataset
end


class RoleType < ActiveRecord::Base
  has_many :roles
end

class Person < ActiveRecord::Base
  has_many :affiliations
  has_many :lter_roles, :through => :affiliations, :conditions => ['role_type_id = ?', RoleType.find_by_name('lter')], :source => :role
end



#ActiveRecord::Base.logger = Logger.new(STDOUT)

reader = CSV.open('roles.txt','r')

#p reader.shift

#output = File.open(ARGV[0],'w')

reader.each do |row|

  person = Person.find_by_person(row[0])
  role = Role.find_by_name(row[1])
  p [row[0], person.id, role.id]
  person.lter_roles << role
  person.save
end


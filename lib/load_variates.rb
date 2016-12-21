require 'csv'
require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  host: 'localhost',
  username: 'bohms',
  database: 'meta_development'
)
  
class Datatable < ActiveRecord::Base
end

class Unit < ActiveRecord::Base
end

class Variate < ActiveRecord::Base
  belongs_to :datatable
  belongs_to :unit
end

# ActiveRecord::Base.logger = Logger.new(STDOUT)

reader = CSV.open('variates.csv', 'r')

p reader.shift

# output = File.open(ARGV[0],'w')

reader.each do |row|
  table = Datatable.find_by(name: row[1])
  next if table.nil?

  u = Unit.find_by(name: row[6])

  v = Variate.new
  v.name = row[0]
  v.datatable = table
  v.weight = row[2]
  v.description = row[3]
  v.missing_value_indicator = row[4]
  v.unit = u
  v.measurement_scale = row[7]
  v.data_type = row[8]
  v.min_valid = row[9]
  v.max_valid = row[10]
  v.precision = row[11]
  v.date_format = row[12]
  v.save

  # p "insert into variates (name, datatable_id, weight, description, " +
  #   "missing_value_indicator, unit_id, measurement_scale, data_type, min_valid, " +
  #   "max_valid, precision, date_format) values (#{row[0]},#{table.id}, " +
  #   "#{row[2]}, #{row[3]},#{row[4]},#{unit_id},#{row[7]}, #{row[8]},#{row[9]}," +
  #   "#{row[10]}, #{row[11]}, #{row[12]} )"
end

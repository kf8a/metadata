require 'csv'
require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'postgresql', 
  :host => 'localhost',
  :username => 'bohms',
  :database => 'meta_development'
)
  
class Dataset < ActiveRecord::Base
  has_and_belongs_to_many :themes
end

class Theme < ActiveRecord::Base
  has_and_belongs_to_many :datasets
end

#ActiveRecord::Base.logger = Logger.new(STDOUT)

reader = CSV.open('ThemeAffiliations.csv','r')

#output = File.open(ARGV[0],'w')

reader.each do |row|
  dataset = Dataset.find_by_dataset(row[0])
  theme = Theme.find_by_title(row[1])

  dataset.themes << theme
  dataset.save
  
  # p "insert into variates (name, datatable_id, position, description, " +
  #   "missing_value_indicator, unit_id, measurement_scale, data_type, min_valid, " +
  #   "max_valid, precision, date_format) values (#{row[0]},#{table.id}, " +
  #   "#{row[2]}, #{row[3]},#{row[4]},#{unit_id},#{row[7]}, #{row[8]},#{row[9]}," +
  #   "#{row[10]}, #{row[11]}, #{row[12]} )"
end


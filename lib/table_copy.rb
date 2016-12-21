require 'rubygems'
gem 'postgres'
require 'dbi'

old_table = DBI.connect('DBI:pg:metadata:localhost')
new_table = DBI.connect('DBI:pg:meta_development:localhost')

sth = old_table.prepare('select * from "DatasetAffiliations"')
sth.execute
while row = sth.fetch do

  dataset_id = new_table.select_one('select id from datasets where dataset like ?', row[1])
  person_id = new_table.select_one('select id from people where person like ?', row[0])
  role_id = new_table.select_one('select id from roles where name like ?', row[2].downcase.strip.chop)
  puts row[0], person_id
  puts row[2], role_id
  puts row[1], dataset_id

  new_table.do("insert into affiliations
              (person_id, role_id, dataset_id, seniority)
              values(?,?,?,?)",
              person_id, role_id, dataset_id, row[3])
end

t.column 'person_id',  :integer
t.column 'role_id',    :integer
t.column 'dataset_id', :integer
t.column 'seniority',  :integer

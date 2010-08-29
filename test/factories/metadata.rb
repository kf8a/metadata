Factory.define :person do |p|
  p.sur_name 'bauer'
  p.given_name 'bill'
end

Factory.define :role do |r|
  r.name 'Emeritus Investigators'
end

Factory.define :theme do |t|
  t.name  'Agronomic'
end

Factory.define :dataset do |d|
  d.title 'KBS001'
  d.abstract 'some new dataset'
end

Factory.define :protocol do |p|
  p.name  'Proto1'
  p.version  0
  p.dataset Factory.create(:dataset)
end

Factory.define :sponsor do |s|
  s.name    'LTER'
end

Factory.define :datatable do |d|
  d.name          'KBS001_001'
  d.title         'a really cool datatable'
  d.object        'select now() as sample_date'
  d.is_sql         true
  d.description   'This is a datatable'
  d.weight        100
  d.theme         Factory.create(:theme)
  d.dataset       Factory.create(:dataset)
end

Factory.define :protected_datatable, :parent => :datatable do |datatable|
  datatable.dataset   Factory.create(:dataset, :sponsor => Factory.create(:sponsor, :data_restricted => true))
end


Factory.define :website do |w|
  w.name 'Name'
end

Factory.define :permission do |p|

end

Factory.define :publication do |p|
  p.citation            'bogus data, brown and company'
  p.abstract            'something in here'
  p.year                2000
  p.publication_type_id 1
end

Factory.define :study do |s|
  s.name 'LTER'
end

Factory.define :template do |t|
end

Factory.define :variate do |v|
  v.name 'date'
end

Factory.define :upload do |u|
end

Factory.define :venue_type do |v|
  v.name  'Venue Name'
end

Factory.define :meeting do |m|
  m.venue_type  Factory.create(:venue_type)
end

Factory.define :abstract do |a|
  a.abstract  'A quick little discussion of the meeting.'
  a.meeting   Factory.create(:meeting)
end

Factory.define :project do |p|
end

Factory.define :ownership do |o|
#  o.user        Factory.create(:user)
#  o.datatable   Factory.create(:datatable)
end

Factory.define :unit do |u|
end

Factory.define :affiliation do |affiliate|
end

Factory.define :citation do |cite|
end

Factory.define :collection do |c|
end
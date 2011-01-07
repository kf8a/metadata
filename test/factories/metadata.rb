#Independent factories#########
Factory.define :affiliation do |affiliate|
end

Factory.define :author do |author|
  author.seniority  1
end

Factory.define :editor do |editor|
  editor.seniority 1
end

Factory.define :citation do |cite|
end

Factory.define :dataset do |d|
  d.title 'KBS001'
  d.abstract 'some new dataset'
end

Factory.define :invite do |i|
  i.sequence(:email) {|n| "person#{n}@example.com" }
end

Factory.define :ownership do |o|
end

Factory.define :page do |p|
end

Factory.define :permission do |p|
end

Factory.define :permission_request do |p|
end

Factory.define :person do |p|
  p.sur_name 'bauer'
  p.given_name 'bill'
end

Factory.define :project do |p|
end

Factory.define :publication do |p|
  p.citation            'bogus data, brown and company'
  p.abstract            'something in here'
  p.year                2000
  p.publication_type_id 1
end

Factory.define :publication_type do |p|
end

Factory.define :role do |r|
  r.name 'Emeritus Investigators'
end

Factory.define :role_type do |r|
  
end

Factory.define :species do |s|
end

Factory.define :sponsor do |s|
  s.name    'LTER'
end

Factory.define :study do |s|
  s.name 'LTER'
end

Factory.define :study_url do |s|
end

Factory.define :unit do |u|
end

Factory.define :upload do |u|
end

Factory.define :template do |t|
end

Factory.define :theme do |t|
  t.name  'Agronomic'
end

Factory.define :variate do |v|
  v.name 'date'
end

Factory.define :venue_type do |v|
  v.name  'Venue Name'
end

Factory.define :website do |w|
  w.name 'Name'
end

#Dependent factories##########

Factory.define :protocol do |p|
  p.name  'Proto1'
  p.version  0
  p.dataset Factory.create(:dataset)
end

Factory.define :datatable do |d|
  d.name          'KBS001_001'
  d.title         'a really cool datatable'
  d.object        "select 1 as sample_date"
  d.is_sql         true
  d.description   'This is a datatable'
  d.weight        100
  d.association   :theme
  d.association   :dataset
end

Factory.define :restricted_sponsor, :parent => :sponsor do |sponsor|
  sponsor.data_restricted   true
end

Factory.define :restricted_dataset, :parent => :dataset do |dataset|
  dataset.association   :sponsor, :factory => :restricted_sponsor
end

Factory.define :protected_datatable, :parent => :datatable do |datatable|
  datatable.association   :dataset, :factory => :restricted_dataset
end

Factory.define :collection do |c|
  c.datatable   Factory.create(:datatable)
end

Factory.define :data_contribution do |d|
  d.person    Factory.create(:person)
  d.role      Factory.create(:role)
  d.datatable Factory.create(:datatable)
end

Factory.define :public_datatable, :parent => :datatable do |datatable|
end

Factory.define :meeting do |m|
  m.venue_type_id    1
end

Factory.define :abstract do |a|
  a.abstract  'A quick little discussion of the meeting.'
  a.association   :meeting
end


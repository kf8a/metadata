Given /^a protected datatable exists$/ do
  @datatable = Factory.create(:protected_datatable)
end

Given /^a protected datatable exists named "([^"]*)"$/ do |name|
  @datatable = Factory.create(:protected_datatable,
    :name     => name,
    :object   => 'select 1 as test',
    :is_sql   => true)
end

Given /^a public datatable exists$/ do
  @datatable = Factory.create(:datatable)
end

Given /^a public datatable exists named "([^"]*)"$/ do |name|
  @datatable = Factory.create(:datatable,
    :name     => name)
end

Given /^a public lter datatable exists titled "([^"]*)"$/ do |title|
  @website = Website.find_by_name("lter")
  @datatable = Factory.create(:datatable,
    :title => title,
    :dataset => Factory.create(:dataset, :website => @website),
    :study => Factory.create(:study))
end

Given /^a public lter datatable exists with species data$/ do
  @website = Website.find_by_name("lter")
  Factory.create(:species,
    :species => "P. leo",
    :genus => "Panthera",
    :family => "Felidae",
    :common_name => "Lion")
  Factory.create(:species,
    :species => "P. tigris",
    :genus => "Panthera",
    :family => "Felidae",
    :common_name => "Tiger")
  Factory.create(:species,
    :species => "U. americanus",
    :genus => "Ursus",
    :family => "Ursidae",
    :common_name => "American Black Bear")
  @datatable = Factory.create(:datatable,
    :object => 'select * from species',
    :dataset => Factory.create(:dataset, :website => @website),
    :study => Factory.create(:study))
  Factory.create(:variate,
    :datatable => @datatable,
    :name => "Species",
    :description => "The name of the species")
  Factory.create(:variate,
    :datatable => @datatable,
    :name => "Genus",
    :description => "The genus of the species")
  Factory.create(:variate,
    :datatable => @datatable,
    :name => "Family",
    :description => "The family of the genus")
  Factory.create(:variate,
    :datatable => @datatable,
    :name => "Common Name",
    :description => "What Joe Public calls the species")
end

Given /^all caches are cleared$/ do
  @controller.expire_fragment(%r{.*})
end
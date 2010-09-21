
Given /^a public lter datatable exists with a title of "([^"]*)"$/ do |title|
  website = Website.find_by_name("lter") || Factory.create(:website, :name => "lter")
  study = Study.find_by_name("Awesome Study") || Factory.create(:study)
  datatable = Factory.create(:datatable,
    :title => title,
    :dataset => Factory.create(:dataset, :website => website),
    :study => study)
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

Given /^the datatable sponsored by "([^"]*)"$/ do |sponsor|
  datatable = Datatable.last
  datatable.dataset.sponsor.name = sponsor
end

Then /^some details should be true$/ do
  study = Study.find_by_name("Awesome Study")
  assert study
  datatable1 = Datatable.find_by_title("First one")
  assert datatable1.study = study
  assert study.include_datatables?([datatable1])
  assert Study.find_all_roots_with_datatables([datatable1], {:order => 'weight'}).include?(study)
end
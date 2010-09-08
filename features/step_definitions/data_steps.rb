Given /^a protected datatable exists$/ do
  @datatable = Factory.create(:protected_datatable)
end

Given /^a protected datatable exists named "([^"]*)"$/ do |name|
  @datatable = Factory.create(:protected_datatable,
    :name     => name,
    :object   => 'select now()',
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
  @datatable = Factory.create(:datatable,
    :object => 'select 1 as test, 2 as more',
    :dataset => Factory.create(:dataset, :website => @website),
    :study => Factory.create(:study))
  Factory.create(:variate,
    :datatable => @datatable,
    :name => "Title",
    :description => "The name of the book")
  Factory.create(:variate,
    :datatable => @datatable,
    :name => "Length",
    :description => "How long the book is",
    :unit => Factory.create(:unit, :name => "pages"))
end

Given /^all caches are cleared$/ do
  @controller.expire_fragment(%r{.*})
end
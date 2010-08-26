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

Given /^all caches are cleared$/ do
  @controller.expire_fragment(%r{.*})
end

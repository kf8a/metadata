Given /^the datatable has a collection$/ do
  datatable = Datatable.last
  collection = Factory.create(:collection, :datatable => datatable)
end

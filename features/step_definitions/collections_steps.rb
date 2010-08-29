Given /^the datatable has a collection$/ do
  @collection = Factory.create(:collection, :datatable => @datatable)
end
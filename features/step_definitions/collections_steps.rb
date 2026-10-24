# frozen_string_literal: true

Given(/^the datatable has a collection$/) do
  datatable = Datatable.last
  Factory.create(:collection, datatable: datatable)
end

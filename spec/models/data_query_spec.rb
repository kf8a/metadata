require 'rails_helper'

describe DataQuery do
  before(:each) do
    50.times { FactoryBot.create :datatable }
  end

  describe 'find in batches' do
    it 'yields several times' do
      query = 'select * from datatables'
      i = 0
      DataQuery.find_in_batches_as_csv(query, {batch_size: 8}) do |a|
        i += 1
      end
      assert i == 7
    end
  end
end

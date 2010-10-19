require File.expand_path('../../test_helper',__FILE__) 

class CollectionTest < ActiveSupport::TestCase

  should belong_to :datatable
  should validate_presence_of :datatable

  context "perform_query method" do
    should "return the result of the database query" do
      @collection = Factory.create(:collection)
      assert @collection.perform_query.class == PGresult
    end
  end

  context "values method" do
    should "be the same as perform_query" do
      @collection = Factory.create(:collection)
      assert @collection.perform_query.to_a == @collection.values.to_a
    end
  end
end

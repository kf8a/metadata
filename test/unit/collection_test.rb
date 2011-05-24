require File.expand_path('../../test_helper',__FILE__) 

class CollectionTest < ActiveSupport::TestCase

  should belong_to :datatable
  should validate_presence_of :datatable

  context "perform_query method" do
    should "return the result of the database query" do
      @collection = Factory.create(:collection)
      assert_instance_of PGresult, @collection.perform_query
    end
  end

  context "values method" do
    should "be the same as perform_query" do
      @collection = Factory.create(:collection)
      assert_equal @collection.perform_query.to_a, @collection.values.to_a
    end
  end
end



# == Schema Information
#
# Table name: collections
#
#  id           :integer         not null, primary key
#  created_at   :datetime
#  updated_at   :datetime
#  datatable_id :integer
#


require File.expand_path('../../test_helper',__FILE__)

class OwnershipTest < ActiveSupport::TestCase

  def setup 
    User.destroy_all
  end


  should belong_to :user
  should belong_to :datatable

  should validate_presence_of :user
  should validate_presence_of :datatable

  context 'An ownership exists' do
    setup do
      User.destroy_all
      Factory.create(:ownership)
    end

    should validate_uniqueness_of(:user_id).scoped_to(:datatable_id)
  end
end

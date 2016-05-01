require File.expand_path('../../test_helper', __FILE__)

class PermissionRequestTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to :datatable

  should validate_presence_of :user
  should validate_presence_of :datatable

  context 'a user has already requested permission for a datatable' do
    setup do
      @user = FactoryGirl.create(:email_confirmed_user)
      @datatable = FactoryGirl.create(:protected_datatable)
      request = FactoryGirl.build(:permission_request, user: @user, datatable: @datatable)
      assert request.save
    end

    should 'not allow a second request for the same user and datatable' do
      request2 = FactoryGirl.build(:permission_request, user: @user, datatable: @datatable)
      assert !request2.save
    end

    should 'allow a second request for the same user different datatable' do
      datatable2 = FactoryGirl.create(:protected_datatable)
      request2 = FactoryGirl.build(:permission_request, user: @user, datatable: datatable2)
      assert request2.save
    end
  end
end

# == Schema Information
#
# Table name: permission_requests
#
#  id           :integer         not null, primary key
#  datatable_id :integer
#  user_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#

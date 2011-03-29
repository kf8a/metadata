require File.expand_path('../../test_helper',__FILE__)

class PermissionRequestTest < ActiveSupport::TestCase

  should belong_to :user
  should belong_to :datatable

  should validate_presence_of :user
  should validate_presence_of :datatable

  context 'a user has already requested persmission for a datatable' do
    setup do
      @user = Factory.create(:email_confirmed_user)
      @datatable = Factory.create(:protected_datatable)
      request = Factory.build(:permission_request, :user => @user, :datatable => @datatable)
      assert request.save
    end

    should 'not allow a second request for the same user and datatable' do
      request2 = Factory.build(:permission_request, :user => @user, :datatable => @datatable)
      assert !request2.save
    end

    should 'allow a second request for the same user different datatable' do
      datatable2 = Factory.create(:protected_datatable)
      request2 = Factory.build(:permission_request, :user => @user, :datatable => datatable2)
      assert request2.save
    end
  end
end

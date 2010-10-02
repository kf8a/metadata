require 'test_helper'

class PermissionRequestTest < ActiveSupport::TestCase

  should belong_to :user
  should belong_to :datatable

  should validate_presence_of :user
  should validate_presence_of :datatable
  
  should "not allow a second request for the same user and datatable" do
    user = Factory.create(:email_confirmed_user)
    datatable = Factory.create(:protected_datatable)
    request1 = Factory.build(:permission_request, :user => user, :datatable => datatable)
    assert request1.save
    request2 = Factory.build(:permission_request, :user => user, :datatable => datatable)
    assert !request2.save
  end
  
  should "allow a second request for the same user different datatable" do
    user = Factory.create(:email_confirmed_user)
    datatable = Factory.create(:protected_datatable)
    datatable2 = Factory.create(:protected_datatable)
    request1 = Factory.build(:permission_request, :user => user, :datatable => datatable)
    assert request1.save
    request2 = Factory.build(:permission_request, :user => user, :datatable => datatable2)
    assert request2.save
  end
end

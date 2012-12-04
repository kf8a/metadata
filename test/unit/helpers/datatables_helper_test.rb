require 'test_helper'

class DatatablesHelperTest < ActionView::TestCase

  def test_permission_request_email_list
    datatable = FactoryGirl.create :datatable
    owner = FactoryGirl.create :user, :email => 'test@person.com'
    datatable.owners << owner
    
    assert permission_request_email_list(datatable) =~ /test/
    assert permission_request_email_list(datatable) =~ /glbrc/
  end
  
  def test_personnel_by_roles
    datatable = FactoryGirl.create :datatable
  end
end

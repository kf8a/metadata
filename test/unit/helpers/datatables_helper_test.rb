require 'test_helper'

class DatatablesHelperTest < ActionView::TestCase

  def test_permission_request_email_list
    datatable = Factory.create :datatable
    owner = Factory.create :user, :email => 'test@person.com'
    datatable.owners << owner
    
    assert permission_request_email_list(datatable) =~ /test/
    assert permission_request_email_list(datatable) =~ /glbrc/
  end
  
  def test_personnel_by_roles
    datatable = Factory.create :datatable
  end
end
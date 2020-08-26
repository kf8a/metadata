require 'test_helper'

class DatatablesHelperTest < ActionView::TestCase
  def test_permission_request_email_list
    datatable = FactoryBot.create :datatable
    owner = FactoryBot.create :user, email: 'test@person.com'
    datatable.owners << owner

    assert permission_request_email_list(datatable) =~ /test/
    assert permission_request_email_list(datatable) =~ /glbrc/
  end
end

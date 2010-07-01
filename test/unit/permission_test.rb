require File.dirname(__FILE__) + '/../test_helper'

class PermissionTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to :datatable
  should belong_to :owner
  
  should validate_presence_of :user
  should validate_presence_of :datatable
  should validate_presence_of :owner
  
  context 'basic permissions' do
    setup do 
      user        = Factory :user
      owner       = Factory :user
      datatable   = Factory :datatable
  
      @permission = Factory :permission,
        :datatable  => datatable,
        :user       => user,
        :owner      => owner
    end
    
    should 'be valid' do
      assert_valid @permission
    end
  end
end

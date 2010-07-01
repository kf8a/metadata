require File.dirname(__FILE__) + '/../test_helper'

class PermissionTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to :datatable
  should belong_to :owner

  # should validate_presence_of :user
  # should validate_presence_of :datatable
  # should validate_presence_of :owner
  
  # TODO figure out how to write a matcher for associated models
  # should_validate_associated :user
  # should_validate_associated :datatable
  # should_validate_associated :owner

  context 'basic permissions' do
    setup do 
      user        = Factory :user
      owner       = Factory :user
      datatable   = Factory :datatable, :owners => [owner]

      @permission = Factory :permission,
        :datatable  => datatable,
        :user       => user,
        :owner      => owner
    end

    should 'be valid' do
      assert_valid @permission
    end
  end

  context 'setting permissions' do
    setup do
      @owner      = Factory :user
      @datatable  = Factory :datatable, :owners => [@owner]
    end

    should 'allow the owner to give users permission' do
      p           = Permission.new({:datatable => @datatable})
      p.owner     = @owner
      p.user      = Factory :user
      
      assert p.valid?
    end

    should 'not allow a non owner to give users permission' do
      p           = Permission.new
      p.datatable = @datatable
      p.owner     = Factory :user
      p.user      = Factory :user
      
      assert !p.valid?
    end

    should 'not allow permissions to be set more than once' 
  end
end

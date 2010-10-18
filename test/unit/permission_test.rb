require File.expand_path('../../test_helper',__FILE__) 

class PermissionTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to :datatable
  should belong_to :owner

  #TODO figure out why it fails with these
  should validate_presence_of :user
  should validate_presence_of :datatable
  should validate_presence_of :owner
  
  # TODO figure out how to write a matcher for associated models
  # should_validate_associated :user
  # should_validate_associated :datatable
  # should_validate_associated :owner

  context 'basic permissions' do
    setup do 
      user        = Factory :user
      owner       = Factory :user
      datatable   = Factory :datatable, :owners => [owner]

      @permission = Factory.build :permission,
        :datatable  => datatable,
        :user       => user,
        :owner      => owner
    end

    should 'be valid' do
      assert @permission.valid?
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

    should 'not allow permissions to be set more than once' do
      user         = Factory :user
      
      p1           = Permission.new
      p1.datatable = @datatable
      p1.owner     = @owner
      p1.user      = user
      
      
      p2           = Permission.new
      p2.datatable = @datatable
      p2.owner     = @owner
      p2.user      = user
       
      #TODO after saving the permission becomes invalid. Don't know if that would cause problems elsewere.
      assert p1.valid?
      assert p1.save  
      assert !p1.valid?
      assert !p2.valid?
    end
  end
end

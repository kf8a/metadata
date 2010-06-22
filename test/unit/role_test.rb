require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < ActiveSupport::TestCase
 
 context 'evaluating a role' do
   setup do 
     @emeritus = Factory.create(:role)
     
     @non_emeritus = Factory.create(:role)
     @non_emeritus.name = 'Something elese'
   end
   
   should 'return true for emeritus role' do
     assert @emeritus.emeritus?
   end
   
   should 'return false for non-emeritus role' do
     assert !@non_emeritus.emeritus?
   end
 end
end

require 'test_helper'

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
 
  context "committee? function" do
    setup do
      @committee_member = Factory.create(:role, :name => "Committee")
      @network_rep = Factory.create(:role, :name => "Network Representatives")
      @non_committee = Factory.create(:role, :name => "Not on a committee")
    end
    
    should "return true for Committee role" do
      assert @committee_member.committee?
    end
    
    should "return true for Network Representatives role" do
      assert @network_rep.committee?
    end
    
    should "return false for non-committee role" do
      assert !@non_committee.committee?
    end
  end
end

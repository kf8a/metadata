require 'test_helper'

class UnitTest < ActiveSupport::TestCase

  context "human_name function" do
    context "and a name with one or more Pers in it" do
      setup do
        @speed = Factory.create(:unit, :name => "FeetPerSecond")
        @acceleration = Factory.create(:unit, :name => "FeetPerSecondPerSecond")
      end
      
      should "replace Per with / and reduce capitals" do
        assert @speed.human_name == "feet/second"
        assert @acceleration.human_name == "feet/second/second"
      end
    end
    
    context "and a name with no Pers in it" do
      setup do
        @distance = Factory.create(:unit, :name => "Feet")
      end
      
      should "just reduce the capitals" do
        assert @distance.human_name == "feet"
      end
    end
    
  end
end

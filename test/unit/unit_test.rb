require File.expand_path('../../test_helper',__FILE__) 

class UnitTest < ActiveSupport::TestCase

  context "human_name function" do
    setup do 
      @speed = Factory :unit, :name => "Feetpersecond", :label => 'ft/2'
    end

    should 'use the label if available' do
      assert_equal 'ft/2', @speed.human_name
    end

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



# == Schema Information
#
# Table name: units
#
#  id                     :integer         not null, primary key
#  name                   :string(255)
#  description            :text
#  in_eml                 :boolean         default(FALSE)
#  definition             :text
#  deprecated_in_favor_of :integer
#  unit_type              :string(255)
#  parent_si              :string(255)
#  multiplier_to_si       :float
#


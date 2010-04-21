require File.dirname(__FILE__) + '/../test_helper'

class PersonTest < ActiveSupport::TestCase
  
  Factory.define :person do |p|
    p.sur_name 'spencer'
    p.given_name 'howard'
  end
  
  Factory.define :role do |r|
    r.name 'Emeritus something'
  end
  
  should_have_many :datatables, :through => :data_contributions
  
  context 'an emeritus' do 
    setup do
      @emeritus = Factory.create(:person, :lter_roles  => [Factory.create(:role)])
    end
  
    should 'return true for @emeritus.only_emeritus?' do
      assert @emeritus.only_emeritus?
    end
  end
  
  context 'a non emeritus person' do
    setup do
      @person = Factory.create(:person, 
        :lter_roles => [Factory.create(:role, :name => 'something else')])
    end
    
    should 'return false for .only_emeritus?' do
      assert !@person.only_emeritus?
    end
    
    should 'return false if one role in non emeritus' do
      @person.lter_roles << Factory.create(:role)
      assert !@person.only_emeritus?
    end
  end
  
  context 'a persons name' do
    setup do
      @person = Factory.create(:person, {:given_name => 'howard', :sur_name => 'spencer'})
      @friendly_person = Factory.create(:person, {:given_name => 'howard', :sur_name => 'spencer', 
          :friendly_name => 'bops'})
    end
    
    should 'return first_name last_name in response to full_name' do
      assert @person.full_name == 'howard spencer'
    end
    
    should 'return last_name, first_name in response to last_name_first' do
      assert @person.last_name_first == 'spencer, howard'
    end
    
    should 'use the friendly_name if available' do
      assert @friendly_person.full_name == 'bops spencer'
      assert @friendly_person.last_name_first == 'spencer, bops'
    end
  end
end

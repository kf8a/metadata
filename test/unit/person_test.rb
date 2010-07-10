require File.dirname(__FILE__) + '/../test_helper'

class PersonTest < ActiveSupport::TestCase
  
  should have_many :datatables
  
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
  
  context 'dealing with non US address' do
    setup do
      @implicit_us_address = Factory.create(:person, {:street_address => '208 Main St.', 
        :city=>'Anytown', :locale => 'CA', :postal_code => '55555'})
      @explicit_us_address = Factory.create(:person,  {:street_address => '208 Main St.', 
          :city=>'Anytown', :locale => 'CA', :postal_code => '55555', :country=>'USA'} )
      @eu_address = Factory.create(:person, {:street_address => 'Hanover Strasse 20', 
          :city=>'Hanover', :postal_code=>'242435', :country=>'Germany'})
    end
    
    should 'usa_address? should return appropriately' do
      assert @implicit_us_address.usa_address?
      assert @explicit_us_address.usa_address?
      assert !@eu_address.usa_address?
    end
    
    should 'return the proper address format for us address' do
      assert @implicit_us_address.address == '208 Main St. Anytown, CA 55555'
      assert @explicit_us_address.address == '208 Main St. Anytown, CA 55555'
    end
    
    should 'return the proper format for eu addresses' do
      assert @eu_address.address == "Hanover Strasse 20\n242435 Hanover Germany"
    end
  end
  
  context 'incomplete addresses' do
    setup do 
      @complete = Factory.create(:person,  {:street_address => '208 Main St.', 
          :city=>'Anytown', :locale => 'CA', :postal_code => '55555', :country=>'USA'} )
      @no_city =     Factory.create(:person,  {:street_address => '208 Main St.', 
               :locale => 'CA', :postal_code => '55555', :country=>'USA'} )
      @city_blank =          Factory.create(:person,  {:street_address => '208 Main St.', 
              :city=>' ', :locale => 'CA', :postal_code => '55555', :country=>'USA'} )
      @city_empty =          Factory.create(:person,  {:street_address => '208 Main St.', 
              :city=>'', :locale => 'CA', :postal_code => '55555', :country=>'USA'} )
      @eu_address = Factory.create(:person, {:street_address => 'Hanover Strasse 20', 
                  :city=>'Hanover', :postal_code=>'242435', :country=>'Germany'})
    end
    
    should 'tell the status of the address' do
      assert @complete.complete_address?
      assert !@no_city.complete_address?
      assert !@city_empty.complete_address?
      assert !@city_blank.complete_address?
      assert @eu_address.complete_address?
    end
  end
end

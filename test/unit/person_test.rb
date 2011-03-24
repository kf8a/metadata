require File.expand_path('../../test_helper',__FILE__) 

class PersonTest < ActiveSupport::TestCase
  
  should have_many :datatables

  context 'a person with some lter_roles' do
    setup do
      @first_role = Factory.create(:lter_role, :name => 'Creators')
      @second_role = Factory.create(:lter_role, :name => 'Owners')
      @person = Factory.create(:person, :lter_roles => [@first_role, @second_role])
    end

    context '#get_all_lter_roles' do
      setup do
        @result = @person.get_all_lter_roles
      end

      should 'return the names as singular' do
        assert @result.include?('Creator')
        assert @result.include?('Owner')
      end
    end

    context 'some of the roles are committee roles' do
      setup do
        @first_committee = Factory.create(:lter_role, :name => 'Committee Members')
        @second_committee = Factory.create(:lter_role, :name => 'Network Representatives')
        assert @first_committee.committee?
        assert @second_committee.committee?
        @person.lter_roles << @first_committee
        @person.lter_roles << @second_committee
      end

      context '#get_committee_roles' do
        setup do
          @result = @person.get_committee_roles
        end

        should 'return only the committee role names' do
          assert @result.include?('Committee Member')
          assert @result.include?('Network Representative')
          assert !@result.include?('Creator')
          assert !@result.include?('Owner')
        end
      end
    end
  end
  
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
    
    should 'return false for #only_emeritus?' do
      assert !@person.only_emeritus?
    end
    
    should 'return false for #only_emeritus? if one role is non emeritus' do
      @person.lter_roles << Factory.create(:role)
      assert !@person.only_emeritus?
    end
  end
  
  context 'a persons name' do
    setup do
      @person = Factory.create(:person, {:given_name => 'howard', :sur_name => 'spencer'})
      @friendly_person = Factory.create(:person, {:given_name => 'howard', :sur_name => 'spencer', 
          :friendly_name => 'bops'})
      @long_name = Factory.create(:person, :given_name => 'Shankurnarayanan', :sur_name => 'Ramachandranathan')
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

    should 'truncate the name if necessary in response to #short_full_name' do
      assert_equal 'bops spencer', @friendly_person.short_full_name
      assert_equal 'howard spencer', @person.short_full_name
      assert_equal 'Shankurnarayanan Ramachandrana...', @long_name.short_full_name
    end
  end
  
  context 'dealing with non US address' do
    setup do
      @implicit_us_address = Factory.create(:person, {:street_address => '208 Main St.', 
        :city=>'Anytown', :locale => 'CA', :postal_code => '55555'})
      @explicit_us_address = Factory.create(:person,  {:street_address => '208 Main St.', 
          :city=>'Anytown', :locale => 'CA', :postal_code => '55555', :country=>'USA'} )
      @less_explicit_us_address = Factory.create(:person,  {:street_address => '208 Main St.',
          :city=>'Anytown', :locale => 'CA', :postal_code => '55555', :country=>'US'} )
      @eu_address = Factory.create(:person, {:street_address => 'Hanover Strasse 20', 
          :city=>'Hanover', :postal_code=>'242435', :country=>'Germany'})
      @empty_country_address = Factory.create(:person, {:street_address => '208 Main St.',
        :city=>'Anytown', :locale => 'CA', :postal_code => '55555', :country => ''})
    end
    
    should 'usa_address? should return appropriately' do
      assert @implicit_us_address.usa_address?
      assert @explicit_us_address.usa_address?
      assert @less_explicit_us_address.usa_address?
      assert !@eu_address.usa_address?
      assert @empty_country_address.usa_address?
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

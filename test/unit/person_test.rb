require File.expand_path('../../test_helper',__FILE__)

class PersonTest < ActiveSupport::TestCase

  should have_many :datatables

  context 'a person' do
    setup do
      @person = FactoryGirl.create(:person, :street_address=> '34 main st. ', :organization => '')
    end

    context 'converted to eml' do
      setup do
        xml = Builder::XmlMarkup.new
        to_eml = @person.to_eml(xml)
        @parsed_eml = Nokogiri::XML(to_eml)
      end

      should 'include the person name' do
        assert_equal 1, @parsed_eml.css("associatedParty").count
      end

      should 'include an individualName element' do
        assert_equal 1, @parsed_eml.css('associatedParty individualName').count
      end

      should 'not include an empty deliveryPoint' do
        assert_equal 1, @parsed_eml.css('deliveryPoint').count
      end
    end

  end

  context 'a person with some lter_roles' do
    setup do
      @first_role = FactoryGirl.create(:lter_role, :name => 'Creators')
      @second_role = FactoryGirl.create(:lter_role, :name => 'Owners')
      @person = FactoryGirl.create(:person, :lter_roles => [@first_role, @second_role])
    end

    context 'some of the roles are committee roles' do
      setup do
        @first_committee = FactoryGirl.create(:lter_role, :name => 'Committee Members')
        @second_committee = FactoryGirl.create(:lter_role, :name => 'Network Representatives')
        assert @first_committee.committee?
        assert @second_committee.committee?
        @person.lter_roles << @first_committee
        @person.lter_roles << @second_committee
      end

      context '#get_committee_role names' do
        setup do
          @result = @person.get_committee_role_names
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
      @emeritus = FactoryGirl.build(:person, :lter_roles  => [FactoryGirl.build(:role)])
    end

    should 'return true for @emeritus.only_emeritus?' do
      assert @emeritus.only_emeritus?
    end
  end

  context 'a non emeritus person' do
    setup do
      @person = FactoryGirl.build(:person,
        :lter_roles => [FactoryGirl.build(:role, :name => 'something else')])
    end

    should 'return false for #only_emeritus?' do
      assert !@person.only_emeritus?
    end

    should 'return false for #only_emeritus? if one role is non emeritus' do
      @person.lter_roles << FactoryGirl.build(:role)
      assert !@person.only_emeritus?
    end
  end

  context 'a persons name' do
    setup do
      @person = FactoryGirl.create(:person, {:given_name => 'howard', :sur_name => 'spencer'})
      @friendly_person = FactoryGirl.create(:person, {:given_name => 'howard', :sur_name => 'spencer',
          :friendly_name => 'bops'})
      @long_name = FactoryGirl.create(:person, :given_name => 'Shankurnarayanan', :sur_name => 'Ramachandranathan')
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
      @implicit_us_address = FactoryGirl.create(:person, {:street_address => '208 Main St.',
        :city=>'Anytown', :locale => 'CA', :postal_code => '55555'})
      @explicit_us_address = FactoryGirl.create(:person,  {:street_address => '208 Main St.',
          :city=>'Anytown', :locale => 'CA', :postal_code => '55555', :country=>'USA'} )
      @less_explicit_us_address = FactoryGirl.create(:person,  {:street_address => '208 Main St.',
          :city=>'Anytown', :locale => 'CA', :postal_code => '55555', :country=>'US'} )
      @eu_address = FactoryGirl.create(:person, {:street_address => 'Hanover Strasse 20',
          :city=>'Hanover', :postal_code=>'242435', :country=>'Germany'})
      @empty_country_address = FactoryGirl.create(:person, {:street_address => '208 Main St.',
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
      full_address = {:street_address => '208 Main St.', :city=>'Anytown',
          :locale => 'CA', :postal_code => '55555', :country=>'USA'}
      @complete = FactoryGirl.create(:person, full_address)
      @no_city =  FactoryGirl.create(:person, full_address.merge(:city => nil))
      @city_blank = FactoryGirl.create(:person, full_address.merge(:city => ' '))
      @city_empty = FactoryGirl.create(:person, full_address.merge(:city => ''))
      @no_street_address = FactoryGirl.create(:person, full_address.merge(:street_address => nil))
      @street_address_blank = FactoryGirl.create(:person, full_address.merge(:street_address => ' '))
      @no_postal_code = FactoryGirl.create(:person, full_address.merge(:postal_code => nil))
      @postal_code_blank = FactoryGirl.create(:person, full_address.merge(:postal_code => ' '))
      @no_locale = FactoryGirl.create(:person, full_address.merge(:locale => nil))
      @locale_blank = FactoryGirl.create(:person, full_address.merge(:locale => ' '))
      @eu_address = FactoryGirl.create(:person, {:street_address => 'Hanover Strasse 20',
                  :city=>'Hanover', :postal_code=>'242435', :country=>'Germany'})
    end

    should 'tell the status of the address' do
      assert @complete.complete_address?
      assert !@no_city.complete_address?
      assert !@city_empty.complete_address?
      assert !@city_blank.complete_address?
      assert !@no_street_address.complete_address?
      assert !@street_address_blank.complete_address?
      assert !@no_postal_code.complete_address?
      assert !@postal_code_blank.complete_address?
      assert !@no_locale.complete_address?
      assert !@locale_blank.complete_address?
      assert @eu_address.complete_address?
    end

    should 'return the proper address format' do
      assert_equal '208 Main St. Anytown, CA 55555', @complete.address
      assert_equal '208 Main St. , CA 55555', @no_city.address
      assert_equal ' Anytown, CA 55555', @no_street_address.address
      assert_equal '208 Main St. Anytown, CA ', @no_postal_code.address
      assert_equal '208 Main St. Anytown,  55555', @no_locale.address
      assert_equal '208 Main St. Anytown,   55555', @locale_blank.address
    end
  end

  #TODO a test needs to be written for find_all_with_dataset

  # personnelDB
  context 'lter_personelDB updates' do
    setup do
      @person = FactoryGirl.create(:person)
    end

    should 'respond to to_lter_personneldb' do
      assert @person.respond_to?('to_lter_personneldb')
    end

    should 'return a basic valid xml structure' do

    end

  end
end





# == Schema Information
#
# Table name: people
#
#  id               :integer         not null, primary key
#  person           :string(255)
#  sur_name         :string(255)
#  given_name       :string(255)
#  middle_name      :string(255)
#  friendly_name    :string(255)
#  title            :string(255)
#  sub_organization :string(255)
#  organization     :string(255)
#  street_address   :string(255)
#  city             :string(255)
#  locale           :string(255)
#  country          :string(255)
#  postal_code      :string(255)
#  phone            :string(255)
#  fax              :string(255)
#  email            :string(255)
#  url              :string(255)
#  deceased         :boolean
#  open_id          :string(255)
#

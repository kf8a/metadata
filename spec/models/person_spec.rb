require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Person do

  describe "eml importation" do
    before(:each) do
      @person = FactoryGirl.create(:person)
    end

    it "should import people" do
      eml_content = @person.to_eml
      eml_element = Nokogiri::XML(eml_content).css('associatedParty').first
      imported_person = Person.from_eml(eml_element)
      imported_person.should == @person
    end

    it "should import new people" do
      @person.given_name = "Tom"
      @person.sur_name = "Jones"
      @person.organization = "MGM Grande Casino"
      @person.city = "Las Vegas"
      @person.locale = "Good locale"
      @person.postal_code = "45550"
      @person.country = "USA"
      @person.phone = "555-555-5555"
      @person.fax = "666-666-6666"
      @person.email = "not_unusual@tobeloved.com"
      role_to_add = RoleType.find_by_name('lter').roles.first
      #role_to_add = Role.first || FactoryGirl.create(:role)
      Affiliation.create!(:person => @person, :role => role_to_add)
      #@person.lter_roles << role_to_add
      @person.save
      assert @person.lter_roles.include?(role_to_add)
      @person.save

      eml_content = @person.to_eml
      person_id = @person.id
      @person.destroy
      assert !Person.exists?(person_id)
      eml_element = Nokogiri::XML(eml_content).css('associatedParty').first
      imported_person = Person.from_eml(eml_element)
      imported_person.given_name.should == "Tom"
      imported_person.sur_name.should == "Jones"
      imported_person.organization.should == "MGM Grande Casino"
      imported_person.city.should == "Las Vegas"
      imported_person.locale.should == "Good locale"
      imported_person.postal_code.should == "45550"
      imported_person.country.should == "USA"
      imported_person.phone.should == "555-555-5555"
      imported_person.fax.should == "666-666-6666"
      imported_person.email.should == "not_unusual@tobeloved.com"
      imported_person.lter_roles.should include(role_to_add)
    end
  end
end
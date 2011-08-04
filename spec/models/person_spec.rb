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
      #@protocol.title = "A sweet title"
      #eml_content = @protocol.to_eml
      #protocol_id = @protocol.id
      #@protocol.destroy
      #assert !Protocol.exists?(protocol_id)
      #eml_element = Nokogiri::XML(eml_content).css('protocol').first
      #imported_protocol = Protocol.from_eml(eml_element)
      #imported_protocol.title.should == "A sweet title"
    end
  end
end

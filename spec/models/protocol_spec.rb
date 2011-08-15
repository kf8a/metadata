require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Protocol do

  describe "eml importation" do
    before(:each) do
      @protocol = FactoryGirl.create(:protocol)
    end

    it "should import protocols" do
      eml_content = @protocol.to_eml
      eml_element = Nokogiri::XML(eml_content).css('methods').first
      imported_protocol = Protocol.from_eml(eml_element)
      imported_protocol.should == @protocol
    end

    it "should import new protocols" do
      @protocol.title = "A sweet title"
      eml_content = @protocol.to_eml
      protocol_id = @protocol.id
      @protocol.destroy
      assert !Protocol.exists?(protocol_id)
      eml_element = Nokogiri::XML(eml_content).css('methods').first
      imported_protocol = Protocol.from_eml(eml_element)
      imported_protocol.title.should == "A sweet title"
      imported_protocol.should be_valid
      assert imported_protocol.save
    end
  end
end

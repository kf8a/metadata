require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Variate do

  describe "eml importation" do
    before(:each) do
      @variate = FactoryGirl.create(:variate, :name => 'EMLVariate', :description => 'A variate test of eml')
    end

    it "should import variates" do
      eml_content = @variate.to_eml
      eml_element = Nokogiri::XML(eml_content).css('attribute').first
      imported_variate = Variate.from_eml(eml_element)
      variate_attributes = @variate.attributes
      variate_attributes.delete('id')
      imported_attributes = imported_variate.attributes
      imported_attributes.delete('id')
      imported_attributes.should == variate_attributes
    end

    it "should import new variates" do
      eml_content = @variate.to_eml
      variate_id = @variate.id
      right_scale = @variate.measurement_scale
      @variate.destroy
      assert !Variate.exists?(variate_id)
      eml_element = Nokogiri::XML(eml_content).css('attribute').first
      imported_variate = Variate.from_eml(eml_element)
      imported_variate.name.should == 'EMLVariate'
      imported_variate.description.should == 'A variate test of eml'
      imported_variate.measurement_scale.should == right_scale
    end

    #TODO add tests for all of the different format types converting from EML
  end
end

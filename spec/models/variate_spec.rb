require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

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
      expect(imported_attributes).to eq variate_attributes
    end

    it "should import new variates" do
      eml_content = @variate.to_eml
      variate_id = @variate.id
      right_scale = @variate.measurement_scale
      @variate.destroy
      assert !Variate.exists?(variate_id)
      eml_element = Nokogiri::XML(eml_content).css('attribute').first
      imported_variate = Variate.from_eml(eml_element)
      expect(imported_variate.name).to eq 'EMLVariate'
      expect(imported_variate.description).to eq 'A variate test of eml'
      expect(imported_variate.measurement_scale).to eq right_scale
    end

    #TODO add tests for all of the different format types converting from EML
  end
end

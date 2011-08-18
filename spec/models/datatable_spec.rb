require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Datatable do

  describe "eml importation" do
    before(:each) do
      @datatable = FactoryGirl.create(:datatable)
    end

    it "should import datatables" do
      eml_content = @datatable.to_eml
      eml_element = Nokogiri::XML(eml_content).css('dataTable').first
      imported_datatable = Datatable.from_eml(eml_element)
      imported_datatable.should == @datatable
    end

    it "should import new datatables" do
      @datatable.name = 'EML Datatable'
      @datatable.title = 'EML Datatable Title'
      @datatable.description = 'EML description'
      protocol = FactoryGirl.create(:protocol)
      @datatable.protocols << protocol
      variate = FactoryGirl.create(:variate, :name => 'EML_variate')
      @datatable.variates << variate
      @datatable.save

      eml_content = @datatable.to_eml
      datatable_id = @datatable.id
      @datatable.destroy
      assert !Datatable.exists?(datatable_id)
      eml_element = Nokogiri::XML(eml_content).css('dataTable').first
      imported_datatable = Datatable.from_eml(eml_element)
      imported_datatable.name.should == 'EML Datatable'
      imported_datatable.title.should == 'EML Datatable Title'
      imported_datatable.description.should == 'EML description'
      imported_datatable.variates.where(:name => "EML_variate").all.should_not be_empty
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

describe Datatable do

  before(:each) do
    @datatable = FactoryGirl.create(:datatable)
  end

  describe 'publishing' do

    before do
      allow(@datatable).to receive(:approved_csv).and_return('something')
      @datatable.publish
    end

    it 'should write a copy of the data to s3' do
      @datatable.csv_cache.exists?.should == true
    end

    after do
      File.unlink("#{Rails.root}/uploads/datatables/csv_caches/#{@datatable.id}.csv")
    end
  end


  # describe "eml importation" do

  #   it "should import datatables" do
  #     eml_content = @datatable.to_eml
  #     eml_element = Nokogiri::XML(eml_content).css('dataTable').first
  #     imported_datatable = Datatable.from_eml(eml_element)
  #     imported_datatable.should == @datatable
  #   end

  #   it "should import new datatables" do
  #     @datatable.name = 'EML Datatable'
  #     @datatable.title = 'EML Datatable Title'
  #     @datatable.description = 'EML description'
  #     protocol = FactoryGirl.create(:protocol)
  #     @datatable.protocols << protocol
  #     variate = FactoryGirl.create(:variate, :name => 'EML_variate')
  #     @datatable.variates << variate
  #     @datatable.save

  #     eml_content = @datatable.to_eml
  #     datatable_id = @datatable.id
  #     @datatable.destroy
  #     assert !Datatable.exists?(datatable_id)
  #     eml_element = Nokogiri::XML(eml_content).css('dataTable').first
  #     dataset = FactoryGirl.create(:dataset, :title => 'Datatablespec dataset')
  #     imported_datatable = dataset.datatables.new
  #     imported_datatable = imported_datatable.from_eml(eml_element)
  #     imported_datatable.name.should == 'EML Datatable'
  #     imported_datatable.title.should == 'EML Datatable Title'
  #     imported_datatable.description.should == 'EML description'
  #     imported_datatable.variates.where(:name => "EML_variate").first.should_not be_nil
  #   end
  # end
end

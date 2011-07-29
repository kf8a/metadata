require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dataset do
  before(:each) do
    @valid_attributes = {
      :title => 'KBS004',
      :abstract => 'the main lter experiment'
    }
  end

  it "should create a new instance given valid attributes" do
    Dataset.create!(@valid_attributes)
  end

  it "should belong to a project" do
    dataset = Dataset.create!(@valid_attributes)
    dataset.project = Project.new
    dataset.save
  end

  describe "eml importation" do
    before(:each) do
      dataset = Factory.create(:dataset, :initiated => Date.today, :completed => Date.today)
      datatable = Factory.create(:datatable)
      @dataset_with_datatable = datatable.dataset
      assert datatable.valid_for_eml
    end

    it "should create consistent eml content when imported and exported" do
      eml_content = @dataset_with_datatable.to_eml
      imported_dataset = Dataset.from_eml(eml_content)
      imported_dataset.should be_a Dataset
      #imported_dataset.to_eml.should == eml_content
    end

    it "should import protocols" do
      new_protocol = FactoryGirl.create(:protocol)
      @dataset_with_datatable.protocols << new_protocol
      @dataset_with_datatable.website = Website.first
      @dataset_with_datatable.save
      eml_content = @dataset_with_datatable.to_eml
      imported_dataset = Dataset.from_eml(eml_content)
      imported_dataset.protocols.should include(new_protocol)
    end
  end
end





# == Schema Information
#
# Table name: datasets
#
#  id           :integer         not null, primary key
#  dataset      :string(255)
#  title        :string(255)
#  abstract     :text
#  old_keywords :string(255)
#  status       :string(255)
#  initiated    :date
#  completed    :date
#  released     :date
#  on_web       :boolean         default(TRUE)
#  version      :integer         default(1)
#  core_dataset :boolean         default(FALSE)
#  project_id   :integer
#  metacat_id   :integer
#  created_at   :datetime
#  updated_at   :datetime
#  sponsor_id   :integer
#  website_id   :integer
#

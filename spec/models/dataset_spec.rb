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

    it "should create a dataset from eml" do
      eml_content = @dataset_with_datatable.to_eml
      imported_dataset = Dataset.from_eml(eml_content)
      imported_dataset.should be_a Dataset
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

    it "should import the right title" do
      @dataset_with_datatable.title = "The right title"
      eml_content = @dataset_with_datatable.to_eml
      imported_dataset = Dataset.from_eml(eml_content)
      imported_dataset.title.should == "The right title"
    end

    it "should import the right abstract" do
      @dataset_with_datatable.abstract = "The right abstract"
      eml_content = @dataset_with_datatable.to_eml
      imported_dataset = Dataset.from_eml(eml_content)
      imported_dataset.abstract.should == "<p>The right abstract</p>" #it will be textilized
    end

    it "should import the right dates" do
      @dataset_with_datatable.initiated = Date.parse("1-2-1988")
      @dataset_with_datatable.completed = Date.parse("3-4-1990")
      eml_content = @dataset_with_datatable.to_eml
      imported_dataset = Dataset.from_eml(eml_content)
      imported_dataset.initiated.should == @dataset_with_datatable.initiated
      imported_dataset.completed.should == @dataset_with_datatable.completed
    end

    it "should import the right people" do
      jon = FactoryGirl.create(:person, :given_name => 'jon')
      @dataset_with_datatable.people << jon
      assert @dataset_with_datatable.save
      eml_content = @dataset_with_datatable.to_eml
      imported_dataset = Dataset.from_eml(eml_content)
      imported_dataset.people.should include(jon)
    end

    it "should import the right datatable" do
      eml_content = @dataset_with_datatable.to_eml
      imported_dataset = Dataset.from_eml(eml_content)
      imported_dataset.datatables.should == @dataset_with_datatable.datatables
    end

    it "should import a dataset from a website" do
      uri = 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-nwt.419.3'
      imported_dataset = Dataset.from_eml(uri)
      imported_dataset.should be_a Dataset
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

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
      imported_dataset.title.should == %Q{Aboveground plant biomass in alpine dry meadow on Niwot Ridge, 1998-2004, for N critical loads ('246') study}
      imported_dataset.abstract.should include %Q{Increases in the deposition of anthropogenic nitrogen (N) have been linked to several terrestrial ecological changes, including soil biogeochemistry, plant stress susceptibility, and community diversity. Recognizing the need to identify sensitive indicators of biotic response to N deposition, we empirically estimated the N critical load for changes in alpine plant community composition and compared this with the estimated critical load for soil indicators of ecological change. We also measured the degree to which alpine vegetation may serve as a sink for anthropogenic N and how much plant sequestration is related to changes in species composition. We addressed these research goals by adding 20, 40, or 60 kg N.ha-1yr-1, along with an ambient control (6 kg N ha-1 yr-1 total deposition), to a species rich alpine dry meadow for an eight-year period. Change in plant species composition associated with the treatments occurred within three years of the initiation of the experiment and were significant at all levels of N addition. Using individual species abundance changes and ordination scores, we estimated the N critical loads (total deposition) for (1) change in individual species to be 4 kg N ha-1 yr-1 and (2) for overall community change to be 10 kg N ha-1 yr-1. In contrast, increases in NO3 leaching, soil solution inorganic NO3, and net N nitrification occurred at levels above 20 kg N ha-1 yr-1. Increases in total aboveground biomass were modest and transient, occurring in only one of the three years measured. Vegetative uptake of N increased significantly, primarily as a result of increasing tissue N concentrations and biomass increases in subdominant species. Aboveground vegetative uptake of N accounted for &lt;40% of the N added. The results of this experiment indicate that changes in vegetation composition will precede detectable changes in more traditionally used soil indicators of ecosystem responses to N deposition and that changes in species composition are probably ongoing in alpine dry meadows of the Front Range of the Colorado Rocky Mountains. Feedbacks to soil N cycling associated with changes in litter quality and species composition may result in only short-term increases in vegetation N pools.}
      imported_dataset.keyword_list.should == ['NWT', 'Niwot Ridge LTER Site', 'LTER', 'Colorado', 'aboveground', 'alpine', 'biomass', 'community change', 'fertilization plot', 'mineralization', 'nitrification', 'nitrogen deposition', 'npp', 'production', 'dry meadow', 'nitrogen cycling', 'primary productivity', 'vascular']
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

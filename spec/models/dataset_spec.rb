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
      imported_dataset.people.where(:given_name => 'jon').should_not be_empty
    end

    it "should import the right datatable" do
      @dataset_with_datatable.datatables.collect{ |table| table.valid_for_eml }.should == [true]
      eml_content = @dataset_with_datatable.to_eml
      old_datatable_attributes = @dataset_with_datatable.datatables.first.attributes
      @dataset_with_datatable.datatables.each {|table| table.destroy}
      @dataset_with_datatable.destroy
      imported_dataset = Dataset.from_eml(eml_content)
      imported_dataset.should be_valid
      new_datatable_attributes = imported_dataset.datatables.first.attributes
      keys_to_ignore = ['id', 'is_sql', 'data_url', 'dataset_id', 'object', 'theme_id', 'created_at', 'updated_at']
      new_datatable_attributes.delete_if {|key, value| keys_to_ignore.include?(key) }
      old_datatable_attributes.delete_if {|key, value| keys_to_ignore.include?(key) }
      new_datatable_attributes.should == old_datatable_attributes
    end

    #TODO: This particular eml is invalid, so redo with a different example eml
    it "should import a dataset from a website" do
      uri = 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-gce.113.13'
      imported_dataset = Dataset.from_eml(uri)
      imported_dataset.should be_a Dataset
      imported_dataset.title.should == %Q{Benthic chlorophyll, density, porosity, and organic content concentrations and gross oxygenic photosynthesis rates in surficial estuarine intertidal sediments at sites on Sapelo Island and near the Satilla River from January, April, June and July 2001}
      imported_dataset.abstract.should include %Q{We propose to establish a Long Term Ecological Research site on the central Georgia coast in the vicinity of Sapelo Island. This is a barrier island and marsh complex with the Altamaha River, one of the largest and least developed rivers on the east coast of the US, as the primary source of fresh water. The proposed study would investigate the linkages between local and distant upland areas mediated by water - surface water and ground water - delivery to the coastal zone. We would explicitly examine the relationship between variability in environmental factors driven by river flow, primarily salinity because we can measure it at high frequency, and ecosystem processes and structure. We will accomplish this by comparing estuary/marsh complexes separated from the Altamaha River by one or two lagoonal estuary/marsh complexes that damp and attenuate the river signal. This spatial gradient is analogous to the temporal trend in riverine influence expected as a result of development in the watershed. We will implement a monitoring system that documents physical and biological variables and use the time trends and spatial distributions of these variables and of their variance structure to address questions about the factors controlling distributions, trophic structure, diversity, and biogeochemistry. An existing GIS-based hydrologic model will be modified to incorporate changes in river water resulting from changes in land use patterns that can be expected as the watershed develops. This model will be linked to ecosystem models and will serve as an heuristic and management tool. Another consequence of coastal development is that as river flow decreases, groundwater flow increases and becomes nutrified. We will compare the effects of ground water discharge from the surficial aquifer in relatively pristine (Sapelo Island) versus more urbanized (mainland) sites to assess the relative importance of fresh water versus nutrients to productivity, structure and biomass turnover rate in marshes influenced by groundwater. We will also investigate the effect of marine processes (tides, storm surge) on mixing across the fresh/salt interface in the surficial aquifer. Additional physical studies will relate the morphology of salt marsh - tidal creek channel complexes to tidal current distributions and exchange. These findings will be incorporated into a physical model that will be coupled to an existing ecosystem model. The land/ocean margin ecosystem lies at the interface between two ecosystems in which distinctly different groups of decomposers control organic matter degradation. The terrestrial ecosystem is largely dominated by fungal decomposers, while bacterial decomposers dominate the marine ecosystem. Both groups are important in salt marsh-dominated ecosystems. Specific studies will examine, at the level of individual cells and hyphae, the relationship bacteria and fungi in the consortia that decompose standing dead Spartina and other marsh plants and examine how, or if, this changes along the salinity gradient.}
      imported_dataset.keyword_list.should == ["Georgia", "Sapelo Island", "USA", "GCE", "LTER", "benthic", "biogeochemistry", "chlorophyll", "density", "organic", "porosity", "sediments", "Primary Production"]
      imported_person = imported_dataset.people.where(:sur_name => "Lee").first
      imported_person.sur_name.should == "Lee"
      imported_person.given_name.should == 'Rosalynn Y.'
      imported_person.organization.should == 'University of Georgia'
      imported_person.email.should == 'rosalynn@uga.edu'
      imported_person.roles.where(:name => 'co-investigator').all.should_not be_empty
      datatable = imported_dataset.datatables.first
      datatable.title.should == 'ALG-GCED-0304c'
      datatable.variates.all.should_not be_empty
      datatable.variates.first.name.should == 'Year'
    #  year_variate = datatable.variates.where(:name => 'year').first
    #  year_variate.should be_a Variate
    #  year_variate.measurement_scale.should == 'dateTime'
    #  year_variate.description.should == 'year'
    #  year_variate.date_format.should == 'YYYY'
    #  id_variate = datatable.variates.where(:name => 'identification code').first
    #  id_variate.should be_a Variate
    #  id_variate.measurement_scale.should == 'nominal'
    #  id_variate.description.should == 'identification code'
    #  block_variate = datatable.variates.where(:name => 'block').first
    #  block_variate.should be_a Variate
    #  block_variate.measurement_scale.should == 'nominal'
    #  block_variate.description.should == 'block'
    #  treatment_variate = datatable.variates.where(:name => 'treatment').first
    #  treatment_variate.should be_a Variate
    #  treatment_variate.measurement_scale.should == 'nominal'
    #  treatment_variate.description.should == 'treatment'
    #  plot_variate = datatable.variates.where(:name => 'plot').first
    #  plot_variate.should be_a Variate
    #  plot_variate.measurement_scale.should == 'nominal'
    #  plot_variate.description.should == 'plot'
    #  kobresia_variate = datatable.variates.where(:name => 'Kobresia myosuroides aboveground biomass').first
    #  kobresia_variate.should be_a Variate
    #  kobresia_variate.measurement_scale.should == 'ratio'
    #  kobresia_variate.unit.name.should == 'gramsPerSquareMeter'
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

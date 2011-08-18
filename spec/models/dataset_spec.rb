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
      new_protocol = FactoryGirl.create(:protocol, :title => 'EML Protocol')
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

    it "should import a dataset from a website" do
      uri = 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-gce.113.13'
      valid_eml_doc?(uri)
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
      year_variate = datatable.variates.where(:name => 'Year').first
      year_variate.should be_a Variate
      year_variate.description.should == 'Year of sample collection'
      year_variate.measurement_scale.should == 'dateTime'
      year_variate.date_format.should == 'YYYY'
      month_variate = datatable.variates.where(:name => 'Month').first
      month_variate.should be_a Variate
      month_variate.description.should == 'Month of sample collection'
      month_variate.measurement_scale.should == 'dateTime'
      month_variate.date_format.should == 'MM'
      day_variate = datatable.variates.where(:name => 'Day').first
      day_variate.should be_a Variate
      day_variate.description.should == 'Day of sample collection'
      day_variate.measurement_scale.should == 'dateTime'
      day_variate.date_format.should == 'DD'
      station_variate = datatable.variates.where(:name => 'Station').first
      station_variate.should be_a Variate
      station_variate.description.should == 'Site location code'
      station_variate.measurement_scale.should == 'nominal'
      zone_variate = datatable.variates.where(:name => 'Zone').first
      zone_variate.should be_a Variate
      zone_variate.description.should == 'Site location zone'
      zone_variate.measurement_scale.should == 'nominal'
      replicate_variate = datatable.variates.where(:name => 'Replicate').first
      replicate_variate.should be_a Variate
      replicate_variate.description.should == 'Sample replicate (number = sample number from across the station, letter = replication at a particular number area)'
      replicate_variate.measurement_scale.should == 'nominal'
      chl_variate = datatable.variates.where(:name => 'Chl_a_Conc').first
      chl_variate.should be_a Variate
      chl_variate.description.should == 'Surface sediment chlorophyll a concentration'
      chl_variate.measurement_scale.should == 'ratio'
      chl_unit = chl_variate.unit
      chl_unit.name.should == 'milligramsPerSquareMeter'
      chl_variate.precision.should == 0.1
      sed_dens_variate = datatable.variates.where(:name => 'Sed_Density').first
      sed_dens_variate.description.should == 'Surface sediment density (grams wet sediment per volume)'
      sed_dens_variate.measurement_scale.should == 'ratio'
      sed_dens_variate.unit.name.should == 'gramsPerCubicCentimeter'
      sed_dens_variate.precision.should == 0.01
      sed_poros_variate = datatable.variates.where(:name => 'Sed_Porosity').first
      sed_poros_variate.description.should == 'Surface sediment porosity (grams water per gram wet sediment)'
      sed_poros_variate.measurement_scale.should == 'ratio'
      sed_poros_variate.unit.name.should == 'dimensionless'
      sed_poros_variate.precision.should == 0.01
      org_variate = datatable.variates.where(:name => 'Organic_Content').first
      org_variate.description.should == 'Organic content (grams per gram dry sediment)'
      org_variate.measurement_scale.should == 'ratio'
      org_variate.unit.name.should == 'dimensionless'
      org_variate.precision.should == 0.01
    end
  end

  it "should not import from an invalid eml url" do
    uri = 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-bnz.81.8'
    error_set = Dataset.from_eml(uri)
    error_set.should_not be_a Dataset
    error_set.first.to_s.should == "Element '{eml://ecoinformatics.org/eml-2.0.1}eml': No matching global declaration available for the validation root."
  end

  def valid_eml_doc?(eml_content)
    xsd = nil
    Dir.chdir("#{Rails.root}/test/data/eml-2.1.0") do
      xsd = Nokogiri::XML::Schema(File.read("eml.xsd"))
    end
    if eml_content.start_with?('http://')
      doc = Nokogiri::XML(open(eml_content))
    else
      doc = Nokogiri::XML(eml_content)
    end
    assert_equal [],  xsd.validate(doc) #we need to make sure the document is valid before trying to import it.
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

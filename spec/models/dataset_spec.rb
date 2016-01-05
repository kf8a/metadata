require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

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
      dataset = FactoryGirl.create(:dataset, :initiated => Date.today, :completed => Date.today)
      datatable = FactoryGirl.create(:datatable)
      @dataset_with_datatable = datatable.dataset
      assert datatable.valid_for_eml?
    end

    it "should create a dataset from eml" do
      eml_content = @dataset_with_datatable.to_eml
      imported_dataset = Dataset.from_eml(eml_content)
      expect(imported_dataset).to be_a Dataset
    end

    it "should import protocols" do
      new_protocol = FactoryGirl.create(:protocol, :title => 'EML Protocol')
      @dataset_with_datatable.protocols << new_protocol
      @dataset_with_datatable.website = Website.first
      @dataset_with_datatable.save
      eml_content = @dataset_with_datatable.to_eml
      imported_dataset = Dataset.from_eml(eml_content)
      expect(imported_dataset.protocols).to include(new_protocol)
    end

    it "should import the right title" do
      @dataset_with_datatable.title = "The right title"
      eml_content = @dataset_with_datatable.to_eml
      imported_dataset = Dataset.from_eml(eml_content)
      expect(imported_dataset.title).to eq "The right title at the Kellogg Biological Station, Hickory Corners, MI "
    end

    it "should import the right abstract" do
      @dataset_with_datatable.abstract = "The right abstract"
      eml_content = @dataset_with_datatable.to_eml
      imported_dataset = Dataset.from_eml(eml_content)
      expect(imported_dataset.abstract).to match /The right abstract/ #it will be textilized
    end

    it "should import the right dates" do
      @dataset_with_datatable.initiated = Date.parse("1-2-1988")
      @dataset_with_datatable.completed = Date.parse("3-4-1990")
      eml_content = @dataset_with_datatable.to_eml
      imported_dataset = Dataset.from_eml(eml_content)
      expect(imported_dataset.initiated).to eq @dataset_with_datatable.initiated
      expect(imported_dataset.completed).to eq @dataset_with_datatable.completed
    end

    it "should import the right people" do
      jon = FactoryGirl.create(:person, :given_name => 'jon')

      @dataset_with_datatable.datatables.first.people << jon

      assert @dataset_with_datatable.save
      eml_content = @dataset_with_datatable.to_eml
      imported_dataset = Dataset.from_eml(eml_content)
      expect(imported_dataset.people.where(:given_name => 'jon')).to_not be_empty
    end

    it "should import the right datatable" do
      expect(@dataset_with_datatable.datatables.collect{ |table| table.valid_for_eml? }).to eq [true]
      eml_content = @dataset_with_datatable.to_eml
      old_datatable_attributes = @dataset_with_datatable.datatables.first.attributes
      @dataset_with_datatable.datatables.each {|table| table.destroy}
      @dataset_with_datatable.destroy
      imported_dataset = Dataset.from_eml(eml_content)
      expect(imported_dataset).to be_valid
      new_datatable_attributes = imported_dataset.datatables.first.attributes
      keys_to_ignore = ['id', 'is_sql', 'data_url', 'dataset_id', 'object', 'theme_id', 'created_at', 'updated_at']
      new_datatable_attributes.delete_if {|key, value| keys_to_ignore.include?(key) }
      old_datatable_attributes.delete_if {|key, value| keys_to_ignore.include?(key) }
      expect(new_datatable_attributes).to eq old_datatable_attributes
    end

    # it "should import a dataset from a website" do
    #   uri = 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-gce.113.13'
    #   valid_eml_doc?(uri)
    #   imported_dataset = Dataset.from_eml(uri)
    #   imported_dataset.should be_a Dataset
    #   imported_dataset.title.should == %Q{Benthic chlorophyll, density, porosity, and organic content concentrations and gross oxygenic photosynthesis rates in surficial estuarine intertidal sediments at sites on Sapelo Island and near the Satilla River from January, April, June and July 2001}
    #   imported_dataset.abstract.should include %Q{We propose to establish a Long Term Ecological Research site on the central Georgia coast in the vicinity of Sapelo Island. This is a barrier island and marsh complex with the Altamaha River, one of the largest and least developed rivers on the east coast of the US, as the primary source of fresh water. The proposed study would investigate the linkages between local and distant upland areas mediated by water - surface water and ground water - delivery to the coastal zone. We would explicitly examine the relationship between variability in environmental factors driven by river flow, primarily salinity because we can measure it at high frequency, and ecosystem processes and structure. We will accomplish this by comparing estuary/marsh complexes separated from the Altamaha River by one or two lagoonal estuary/marsh complexes that damp and attenuate the river signal. This spatial gradient is analogous to the temporal trend in riverine influence expected as a result of development in the watershed. We will implement a monitoring system that documents physical and biological variables and use the time trends and spatial distributions of these variables and of their variance structure to address questions about the factors controlling distributions, trophic structure, diversity, and biogeochemistry. An existing GIS-based hydrologic model will be modified to incorporate changes in river water resulting from changes in land use patterns that can be expected as the watershed develops. This model will be linked to ecosystem models and will serve as an heuristic and management tool. Another consequence of coastal development is that as river flow decreases, groundwater flow increases and becomes nutrified. We will compare the effects of ground water discharge from the surficial aquifer in relatively pristine (Sapelo Island) versus more urbanized (mainland) sites to assess the relative importance of fresh water versus nutrients to productivity, structure and biomass turnover rate in marshes influenced by groundwater. We will also investigate the effect of marine processes (tides, storm surge) on mixing across the fresh/salt interface in the surficial aquifer. Additional physical studies will relate the morphology of salt marsh - tidal creek channel complexes to tidal current distributions and exchange. These findings will be incorporated into a physical model that will be coupled to an existing ecosystem model. The land/ocean margin ecosystem lies at the interface between two ecosystems in which distinctly different groups of decomposers control organic matter degradation. The terrestrial ecosystem is largely dominated by fungal decomposers, while bacterial decomposers dominate the marine ecosystem. Both groups are important in salt marsh-dominated ecosystems. Specific studies will examine, at the level of individual cells and hyphae, the relationship bacteria and fungi in the consortia that decompose standing dead Spartina and other marsh plants and examine how, or if, this changes along the salinity gradient.}
    #   imported_dataset.keyword_list.should == ["Georgia", "Sapelo Island", "USA", "GCE", "LTER", "benthic", "biogeochemistry", "chlorophyll", "density", "organic", "porosity", "sediments", "Primary Production"]
    #   imported_person = imported_dataset.people.where(:sur_name => "Lee").first
    #   imported_person.sur_name.should == "Lee"
    #   imported_person.given_name.should == 'Rosalynn Y.'
    #   imported_person.organization.should == 'University of Georgia'
    #   imported_person.email.should == 'rosalynn@uga.edu'
    #   imported_person.roles.where(:name => 'co-investigator').all.should_not be_empty
    #   datatable = imported_dataset.datatables.first
    #   datatable.title.should == 'ALG-GCED-0304c'
    #   datatable.variates.all.should_not be_empty
    #   year_variate = datatable.variates.where(:name => 'Year').first
    #   year_variate.should be_a Variate
    #   year_variate.description.should == 'Year of sample collection'
    #   year_variate.measurement_scale.should == 'dateTime'
    #   year_variate.date_format.should == 'YYYY'
    #   month_variate = datatable.variates.where(:name => 'Month').first
    #   month_variate.should be_a Variate
    #   month_variate.description.should == 'Month of sample collection'
    #   month_variate.measurement_scale.should == 'dateTime'
    #   month_variate.date_format.should == 'MM'
    #   day_variate = datatable.variates.where(:name => 'Day').first
    #   day_variate.should be_a Variate
    #   day_variate.description.should == 'Day of sample collection'
    #   day_variate.measurement_scale.should == 'dateTime'
    #   day_variate.date_format.should == 'DD'
    #   station_variate = datatable.variates.where(:name => 'Station').first
    #   station_variate.should be_a Variate
    #   station_variate.description.should == 'Site location code'
    #   station_variate.measurement_scale.should == 'nominal'
    #   zone_variate = datatable.variates.where(:name => 'Zone').first
    #   zone_variate.should be_a Variate
    #   zone_variate.description.should == 'Site location zone'
    #   zone_variate.measurement_scale.should == 'nominal'
    #   replicate_variate = datatable.variates.where(:name => 'Replicate').first
    #   replicate_variate.should be_a Variate
    #   replicate_variate.description.should == 'Sample replicate (number = sample number from across the station, letter = replication at a particular number area)'
    #   replicate_variate.measurement_scale.should == 'nominal'
    #   chl_variate = datatable.variates.where(:name => 'Chl_a_Conc').first
    #   chl_variate.should be_a Variate
    #   chl_variate.description.should == 'Surface sediment chlorophyll a concentration'
    #   chl_variate.measurement_scale.should == 'ratio'
    #   chl_unit = chl_variate.unit
    #   chl_unit.name.should == 'milligramsPerSquareMeter'
    #   chl_variate.precision.should == 0.1
    #   sed_dens_variate = datatable.variates.where(:name => 'Sed_Density').first
    #   sed_dens_variate.description.should == 'Surface sediment density (grams wet sediment per volume)'
    #   sed_dens_variate.measurement_scale.should == 'ratio'
    #   sed_dens_variate.unit.name.should == 'gramsPerCubicCentimeter'
    #   sed_dens_variate.precision.should == 0.01
    #   sed_poros_variate = datatable.variates.where(:name => 'Sed_Porosity').first
    #   sed_poros_variate.description.should == 'Surface sediment porosity (grams water per gram wet sediment)'
    #   sed_poros_variate.measurement_scale.should == 'ratio'
    #   sed_poros_variate.unit.name.should == 'dimensionless'
    #   sed_poros_variate.precision.should == 0.01
    #   org_variate = datatable.variates.where(:name => 'Organic_Content').first
    #   org_variate.description.should == 'Organic content (grams per gram dry sediment)'
    #   org_variate.measurement_scale.should == 'ratio'
    #   org_variate.unit.name.should == 'dimensionless'
    #   org_variate.precision.should == 0.01
    # end
  end

  # it "should not import from an invalid eml url" do
  #   uri = 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-bnz.81.8'
  #   error_set = Dataset.from_eml(uri)
  #   error_set.should_not be_a Dataset
  #   error_set.first.to_s.should == "Element '{eml://ecoinformatics.org/eml-2.0.1}eml': No matching global declaration available for the validation root."
  # end

  # it "should import another eml url" do
  #   uri = 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-hfr.113.24'
  #   dataset = Dataset.from_eml(uri)
  #   dataset.should be_a Dataset
  #   dataset.title.should == 'Ants Under Climate Change'
  #   dataset.abstract.should == %Q{Experimental field studies are needed to understand the consequences of global climatic changefor local community structure and associated ecosystem processes. We are using 5-m diameter open-top environmental chambers and 1m pvc minichambers to simultaneously manipulate air and soil temperatures at the Harvard Forest and at the Duke Forest in North Carolina. These field manipulations are designed to reveal the effects of temperature increases on the populations, communities, and associated ecosystem services of assemblages of ground-foraging ants. Ants are a model taxon for studying effects of global climatic change because they comprise the dominant fraction of animal biomass in many terrestrial communities and because they provide essential ecosystem services, including soil turnover, decomposition, and seed dispersal. The experiment is designed to test three predictions: 1. Projected atmospheric warming will lead to declines in ant species’ abundances at the warmer, southern extent of their ranges in the US. Conversely, projected atmospheric warming will lead to increases in abundance or range extensions of ant species at the cooler, northern extent of their ranges in the US. 2. Warming will change the relative abundance and composition of ant communities, and will lead to the loss of ant biodiversity. 3. Warming will potentially diminish ecosystem processes and services provided by ants, particularly with respect to the dispersal of seeds. To explore these, we are conducting two experiments. In one experiment, twelve open-top chambers at each site which will each be exposed air temperatures ranging from 1.5 to 7 deg C above ambient; soil temperatures will be increased simultaneously from 0 to ~ 2 deg C. After an initial year of pre-intervention measurements, the experiment will run for 3 consecutive years of continuous warming. In the second experiment, shade cloth and plastic greenhouse sheeting will be used to increase or decrease temperature by 0.5 deg C in sixty minichambers. The minichamber experiment was conducted in 2009 and will continue into 2010. The response variables measured in both experiments include ant activity, population densities and colony sizes of focal species, ant community diversity and species composition, and rates of seed dispersal and predation as mediated by ants.}
  #   dataset.keyword_list.should == ["ants", "assembly rules", "climate change", "warming"]
  #   person = dataset.people.where(:sur_name => "Boudreau").first
  #   person.given_name.should == "Mark"
  #   person.roles.where(:name => "Researcher").all.should_not be_empty
  #   gotelli = dataset.people.where(:sur_name => 'Gotelli').first
  #   gotelli.given_name.should == "Nicholas"
  #   gotelli.roles.where(:name => "Researcher").all.should_not be_empty
  #   mccoy = dataset.people.where(:sur_name => 'McCoy').first
  #   mccoy.given_name.should == "Neil"
  #   mccoy.roles.where(:name => "Researcher").all.should_not be_empty
  #   pelini = dataset.people.where(:sur_name => 'Pelini').first
  #   pelini.given_name.should == "Shannon"
  #   pelini.roles.where(:name => "Researcher").all.should_not be_empty
  #   sanders = dataset.people.where(:sur_name => 'Sanders').first
  #   sanders.given_name.should == "Nathan"
  #   sanders.roles.where(:name => "Researcher").all.should_not be_empty
  #   chamber_datatable = dataset.datatables.where(:title => 'hf113-01-hf-chamber.csv').first
  #   chamber_datatable.description.should == 'HF chamber data'
  #   chamber_datatable.variates.should_not be_empty
  #   datetime = chamber_datatable.variates.where(:name => 'datetime').first
  #   datetime.description.should == 'time stamp'
  #   datetime.measurement_scale.should == 'dateTime'
  #   datetime.date_format.should == 'MM/DD/YYYY hh:mm'
  #   julian_day = chamber_datatable.variates.where(:name => 'JD').first
  #   julian_day.description.should == 'Julian Day'
  #   julian_day.measurement_scale.should == 'dateTime'
  #   julian_day.date_format.should == 'DDD'
  #   chamber_number = chamber_datatable.variates.where(:name => 'Chamber').first
  #   chamber_number.description.should == 'chamber number (1-12)'
  #   chamber_number.measurement_scale.should == 'nominal'
  #   cat_avg = chamber_datatable.variates.where(:name => 'CAT1_Avg').first
  #   cat_avg.description.should == 'chamber air temperature 1 -average'
  #   cat_avg.measurement_scale.should == 'ratio'
  #   cat_avg.unit.name.should == 'celsius'
  #   cat_avg.precision.should == 0.001
  #   cq_avg = chamber_datatable.variates.where(:name => 'CQ_Avg').first
  #   cq_avg.description.should == 'chamber quantum sensor flux density - average'
  #   cq_avg.measurement_scale.should == 'ratio'
  #   cq_avg.unit.name.should == 'micromolePerMeterSquaredPerSecond'
  #   cq_avg.precision.should == 0.001
  #   chamber_datatable_2 = dataset.datatables.where(:title => 'hf113-02-hf-chamber-since-2009.csv').first
  #   chamber_datatable_2.should be_a Datatable
  #   plate_datatable = dataset.datatables.where(:title => 'hf113-04-hf-hfp.csv').first
  #   plate_avg = plate_datatable.variates.where(:name => 'SHF_Avg(1)').first
  #   plate_avg.precision.should == 0.000001
  #   propane_datatable = dataset.datatables.where(:title => 'hf113-07-hf-propane-hourly.csv').first
  #   ants_high = propane_datatable.variates.where(:name => 'Ants1_high_Avg').first
  #   ants_high.description.should == 'average water temperature of supply on Ants Block #1'
  #   thermal_datatable = dataset.datatables.where(:title => 'hf113-23-hf-thermal.csv').first
  #   length = thermal_datatable.variates.where(:name => 'Length').first
  #   length.description.should == %Q{body length, quantified as Weber's length (see Brown WL (1953) Revisionary studies in the ant tribe Dacetini. Am Midl Nat 50:1-137)}
  #   twc = thermal_datatable.variates.where(:name => 'TWC').first
  #   twc.description.should == %Q{total water content, calculated as (( Live mass - Dry mass ) × 100 ) / Live mass (see Schilman PE, Lighton JRB, Holway DA (2007) Water balance in the Argentine ant (Linepithema humile) compared with five common native ant species from southern California. Physiol Entomol 32 (1):1-7.)}
  #   twc.precision.should == 0.000000001
  #   barcode_datatable = dataset.datatables.where(:title => 'hf113-30-hf-spider-barcode.csv').first
  #   lat = barcode_datatable.variates.where(:name => 'Lat').first
  #   lat.measurement_scale.should == 'interval'
  #   lat.precision.should == 0.0000000001
  # end

  # it 'should work with a few other eml docs' do
  #   uri = 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-ntl.218.6'
  #   errors = Dataset.from_eml(uri)
  #   errors.first.to_s.should == "Element '{eml://ecoinformatics.org/eml-2.0.1}eml': No matching global declaration available for the validation root."

  #   uri = 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-vcr.174.5'
  #   dataset = Dataset.from_eml(uri)
  #   dataset.title.should == 'Biomass of benthic macroalgae in Virginia Coastal Bays'

  #   uri = 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-ntl.160.3'
  #   errors = Dataset.from_eml(uri)
  #   errors.first.to_s.should == "Element '{eml://ecoinformatics.org/eml-2.0.1}eml': No matching global declaration available for the validation root."

  #   uri = 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-hfr.152.2'
  #   dataset = Dataset.from_eml(uri)
  #   dataset.title.should == 'Detection Histories for Hemlock Woolly Adelgid Infestations at Cadwell Forest'

  #   uri = 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-pie.19.4'
  #   errors = Dataset.from_eml(uri)
  #   errors.first.to_s.should == "Element '{eml://ecoinformatics.org/eml-2.0.1}eml': No matching global declaration available for the validation root."

  #   uri = 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-ntl.93.5'
  #   errors = Dataset.from_eml(uri)
  #   errors.first.to_s.should == "Element '{eml://ecoinformatics.org/eml-2.0.1}eml': No matching global declaration available for the validation root."

  #   uri = 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-hfr.81.10'
  #   dataset = Dataset.from_eml(uri)
  #   dataset.title.should == "Landscape Response to Hemlock Woolly Adelgid in Southern New England"

  #   uri = 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-bnz.83.8'
  #   errors = Dataset.from_eml(uri)
  #   errors.first.to_s.should == "Element '{eml://ecoinformatics.org/eml-2.0.1}eml': No matching global declaration available for the validation root."

  #   uri = 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-sgs.6.1'
  #   errors = Dataset.from_eml(uri)
  #   errors.first.to_s.should == "Element '{eml://ecoinformatics.org/eml-2.0.1}eml': No matching global declaration available for the validation root."

  #   uri = 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-sgs.7.1'
  #   errors = Dataset.from_eml(uri)
  #   errors.first.to_s.should == "Element '{eml://ecoinformatics.org/eml-2.0.1}eml': No matching global declaration available for the validation root."

  #   uri = 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-and.4033.4'
  #   errors = Dataset.from_eml(uri)
  #   errors.first.to_s.should == "Element '{eml://ecoinformatics.org/eml-2.0.0}eml': No matching global declaration available for the validation root."

  #   uri = 'http://metacat.lternet.edu:8080/knb/metacat?action=read&qformat=xml&docid=knb-lter-and.4027.7'
  #   valid_eml_doc?(uri)
  #   dataset = Dataset.from_eml(uri)
  #   dataset.title.should == "Aquatic Vertebrate Population Study, Mack Creek, Andrews Experimental Forest"
  # end

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

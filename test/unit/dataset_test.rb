require File.expand_path('../../test_helper',__FILE__) 

class DatasetTest < ActiveSupport::TestCase
    
  should have_many :datatables
  should have_many :affiliations
  should belong_to :website
  
  should have_and_belong_to_many :themes
  should have_and_belong_to_many :studies
  
  
  context 'dataset' do
    setup do
      @dataset = Factory.create(:dataset)
    end

    should 'respond to update_temporal_extent' do
      assert @dataset.respond_to?('update_temporal_extent')
    end

    should 'respond to temporal extent' do
      assert @dataset.respond_to?('temporal_extent')
    end
  end

  context 'to_label function' do
    setup do
      @dataset = Factory.create(:dataset, :title => 'LabelTitle', :dataset => 'Label Dataset')
    end

    should "provide the title and dataset" do
      assert_equal "LabelTitle (Label Dataset)", @dataset.to_label
    end

  end

  context 'datatable_people function' do
    context 'for a dataset with datatables and people' do
      setup do
        @dataset = Factory.create(:dataset)
        datatable1 = Factory.create(:datatable, :dataset => @dataset)
        @dataset.reload
        datatable2 = Factory.create(:datatable, :dataset => @dataset)
        @dataset.reload
        @person1 = Factory.create(:person, :given_name => "Angela")
        @person2 = Factory.create(:person, :given_name => "Bob")
        assert DataContribution.create(:datatable => datatable1, :person => @person1, :role => Factory.create(:role))
        datatable1.reload
        @dataset.reload
        assert DataContribution.create(:datatable => datatable2, :person => @person2, :role => Factory.create(:role))
        datatable2.reload
        @dataset.reload
      end

      should 'list all people' do
        @dataset.reload
        assert @dataset.datatable_people.include?(@person1)
        assert @dataset.datatable_people.include?(@person2)
      end
    end
  end

  context 'no temporal extent' do
    setup do
      @dataset = Factory.create(:dataset, :initiated => '2000-1-1', 
        :datatables => [Factory.create(:datatable, :object => 'select 1')])
    end
    
    should 'not update temporal extent if extent is missing' do
      @dataset.update_temporal_extent
      assert @dataset.initiated == Date.parse('2000-1-1')
      assert @dataset.completed == nil
    end
  end
   
  context 'Current Temporal Extent' do
    setup do
      @dataset = Factory.create(:dataset, 
        :datatables  => [Factory.create(:datatable, :object => 'select 1'), 
                         Factory.create(:datatable, 
                         :object => "select now() as sample_date"),
                         Factory.create(:datatable, :object => 'select 1')])
    end
  
    should 'be today' do
      dates = @dataset.temporal_extent
      assert  dates[:begin_date] == Date.today
      assert dates[:end_date] == Date.today
    end
    
    should 'update temporal extent to today' do
      @dataset.update_temporal_extent
      assert @dataset.initiated == Date.today
      assert @dataset.completed == Date.today
    end

  end
  
  context 'past temporal extent' do
    setup do
      @dataset = Factory.create(:dataset, 
        :datatables  => [Factory.create(:datatable, :object => 'select now() as sample_date'), 
                         Factory.create(:datatable, 
                         :object => "select now() - interval '1 year' as sample_date")])
    end
    
    should 'be today to a year ago' do
      dates = @dataset.temporal_extent
      assert  dates[:begin_date] == Date.today - 1.year
      assert dates[:end_date] == Date.today
    end
    
    
  end
  
  context 'eml generatation' do
    setup do 
      @dataset = Factory.create(:dataset, :initiated => Date.today, :completed => Date.today)
      @dataset_with_datatable = Factory.create(:dataset, :datatables  => [Factory.create(:datatable),  Factory.create(:datatable)])    
    end
    
    should 'be successful' do
      assert !@dataset.to_eml.nil?
      assert !@dataset_with_datatable.to_eml.nil?
    end

    context 'dataset with protocols in the datatables' do
      setup do
        protocol = Factory.create(:protocol)
        @dataset.protocols << protocol
      end

      should 'have a methods section' 
    end
  end
  
  context 'set affiliations' do
    setup do
      @dataset = Factory.create(:dataset)
    end
    
    should 'be able to add a affiliation when none exists' do
      params = { :dataset=>{"title"=>"Trace Gas Fluxes on the Main Cropping System Experiment",
       "abstract"=>"Trace gases (methane,
       carbon dioxide and nitrous oxide) have been measured on the LTER main experimental site since 1991 and on the successional and forested sites since 1993.  The trace gas fluxes are analyzed twice monthly or monthly until the ground freezes.  Samples are collected from permanently-installed in-situ static chambers. CH<sub>4</sub> and N<sub>2</sub>O are analyzed using gas-chromatography and CO<sub>2</sub> is measured with an infrared gas analyzer. Soil moisture and temperature are measured at the same time the gas samples are collected.",
       "keyword_list"=>"CO2,
       flux,
       N2O,
       CH4,
       methane,
       carbon dioxide,
       nitrous oxide,
       gas flux,
       gases,
       agriculture,
       trace gases",
       "website_id"=>"1",
       "sponsor_id"=>"1",
       "status"=>"active",
       "initiated(1i)"=>"1991",
       "initiated(2i)"=>"6",
       "initiated(3i)"=>"12",
       "completed(1i)"=>"2009",
       "completed(2i)"=>"10",
       "completed(3i)"=>"9",
       "core_dataset"=>"1",
       "affiliations_attributes"=>[{"person_id"=>"158",
       "seniority"=>"1"}]},
       "commit"=>"Update",
       "id"=>"16"}
       
      assert @dataset.update_attributes(params[:dataset])
    end
  end
  
  context "within_interval? function" do
    setup do
      @dataset = Factory.create(:dataset)
    end
    
    context "and two datatables" do
      setup do
        Factory.create(:datatable, :dataset => @dataset, 
          :object => 'select now() as sample_date',  
          :begin_date => (Date.today - 7),   :end_date => (Date.today - 4))
        Factory.create(:datatable, :dataset => @dataset, 
          :object => %q{select now() - interval '1 year' as sample_date}, 
          :begin_date => (Date.today - 365), :end_date => (Date.today - 364))
      end
      
      should "return true for dates which include a datatable" do
        assert @dataset.within_interval?(Date.today - 10, Date.today)
      end
      
      should "return false for dates which do not include a datatable" do
        assert !@dataset.within_interval?(Date.today - 500, Date.today - 400)
      end
    end
  end
end

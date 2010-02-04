require File.dirname(__FILE__) + '/../test_helper'

class DatasetTest < ActiveSupport::TestCase
    
  should_have_many :datatables
  should_have_many :affiliations
    
  should_have_and_belong_to_many :themes
  should_have_and_belong_to_many :studies
  
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
        :datatables  => [Factory.create(:datatable), 
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
      @dataset_no_date = Factory.create(:dataset, :datatables  => [Factory.create(:datatable),  Factory.create(:datatable)])    
    end
    
    should 'be successful' do
      assert !@dataset.to_eml.nil?
      assert !@dataset_no_date.to_eml.nil?
    end
  end

  context "Finding Datasets" do
    
    setup do
      @person = Factory.create(:person)
      @study = Factory.create(:study)
      @dataset = Factory.create(:dataset,:keyword_list => 'earth,wind,fire', :people => [@person], 
            :datatables=>[Factory.create(:datatable)])
      @dataset.studies << @study
      
      #future dataset
      study2 = Factory.create(:study)
      dataset2 = Factory.create(:dataset,:keyword_list => 'fire', 
                  :datatables=>[Factory.create(:datatable, {:object => %q{select now() + '2 year' as sample_date}})])
      dataset2.studies << study2
      
      @unfound_dataset = Factory.create(:dataset, :keyword_list => 'wildfire')
      @unfound_study = Factory.create(:study)
      @unfound_dataset.studies << @unfound_study
            
      @theme = Factory.create(:theme, :datasets => [@dataset])
      # make sure we have an up to date extent
      @dataset.update_temporal_extent
    end
    
    should 'respond to within_interval?' do
      assert @dataset.respond_to?('within_interval?')
    end
    
    should 'return yes for todays dataset' do
      assert @dataset.within_interval?(Date.today, Date.today)
    end
  
    should 'respond to find_by_year' do
       assert Dataset.respond_to?('find_by_year')
     end
         
    should 'not find a dataset from last year' do
      assert Dataset.find_by_year(Date.today - 1.year - 1.month, Date.today - 1.year - 1.day) == []
    end
    
    should 'find a dataset if called  with the year' do
      assert Dataset.find_by_year(Date.today.year, Date.today.year) == [@dataset]
    end
          
    should 'respond to find_by_keywords' do
      assert Dataset.respond_to?('find_by_keywords')
    end
    
    should 'find one dataset by keyword earth' do
      assert Dataset.find_by_keywords('earth') == [@dataset]
    end
    
    should 'handle more than one keyword' do
      assert Dataset.find_by_keywords('earth,wind') == [@dataset]
    end
    
    should 'not find a dataset by a wrong keyword' do
      assert Dataset.find_by_keywords('noise') == []
    end
    
    should 'respond to find_by_person' do
      assert Dataset.find_by_person(Person.find(:first))
    end
    
    should 'find a dataset by person_id' do
      assert Dataset.find_by_person(@person) == [@dataset]
    end
    
    should 'not find a dataset by wrong person_id' do
      assert Dataset.find_by_person(5) == []
    end
    
    should 'not find a dataset with an empty person' do
      assert Dataset.find_by_person('') == []
    end
    
    should 'respond to find_by_theme' do
      assert Dataset.find_by_theme(@theme)
    end
    
    should 'find one dataset by theme @theme' do
      assert Dataset.find_by_theme(@theme) == [@dataset]
    end
    
    should 'find the dataset by theme id' do
      assert Dataset.find_by_theme(@theme.id) == [@dataset]
      assert Dataset.find_by_theme(@theme.id.to_s) == [@dataset]
    end
    
    should 'not find a dataset with a new theme' do
      new_theme = Factory.create(:theme)
      assert Dataset.find_by_theme(new_theme) == []
    end
    
    should 'not find a dataset with an empty string for theme' do
      assert Dataset.find_by_theme('') == []
    end
    
    should 'respond to find_by_study' do
      assert Dataset.respond_to?('find_by_study') 
    end
    
    should 'find the right dataset with study' do
      assert Dataset.find_by_study(@study) == [@dataset]
      assert Dataset.find_by_study(@study.id) == [@dataset]
      assert Dataset.find_by_study(@study.id.to_s) == [@dataset]
    end
    
    should 'not find the wrong dataset with study' do
      new_study = Factory.create(:study)
      assert Dataset.find_by_study(@unfound_study) == [@unfound_dataset]
      assert Dataset.find_by_study(new_study) == []
      assert Dataset.find_by_study(new_study.id) == []
      assert Dataset.find_by_study(new_study.id.to_s) == []
    end
    
    should 'respond to find_by_params' do
      assert Dataset.respond_to?('find_by_params')
    end
    
    should 'find one dataset if called with one findable parameter' do
      params = {:theme => {:id => @theme.id.to_s}}
      assert Dataset.find_by_params(params) == [@dataset]
      params = {:person => {:id => @person}}
      assert Dataset.find_by_params(params) == [@dataset]
      params = {:keywords => 'wind'}
      assert Dataset.find_by_params(params) == [@dataset]
      params = {:study => {:id => @study.id}}
      assert Dataset.find_by_params(params) == [@dataset]
      params = {:date => {:syear => Date.today.year, :eyear => Date.today.year}}
      assert Dataset.find_by_params(params) == [@dataset]
      
    end
    
    should 'not find dataset if called with  wrong theme' do
      t = Factory.create(:theme)
      params = {:theme => {:id => t.id}}
      assert Dataset.find_by_params(params) == []
    end
    
    should 'not find dataset if called with wrong person' do
      p = Factory.create(:person)
      params = {:person => {:id  => p.id}}
      assert Dataset.find_by_params(params) == []
    end
    
    should 'find one dataset if called with multiple findable parameters' do
      params = {:theme => {:id => @theme.id}, :person => {:id => @person.id}}
      assert Dataset.find_by_params(params) == [@dataset]
      params = {:theme => {:id => @theme}, :keywords => 'wind'}
      assert Dataset.find_by_params(params) == [@dataset]
      params = {:study => {:id => @study}, :theme => {:id => ''}, :person => {:id => ''},
          :date => {:syear => Date.today.year, :eyear => Date.today.year + 3}}
      assert Dataset.find_by_params(params) == [@dataset]
      params = params = {:study => {:id => nil}, :theme => {:id => ''}, :person => {:id => ''},
          :date => {:syear => Date.today.year, :eyear => Date.today.year + 3},
          :keywords => 'earth'}
      assert Dataset.find_by_params(params) == [@dataset]
    end
    
    should 'find one datasetif a parameter is empty' do    
      params = {:theme => {:id => ''}, :person => {:id => @person}}
      assert Dataset.find_by_params(params) == [@dataset]
      
      params = {:theme => {:id => nil}, :person => {:id => @person}}
      assert Dataset.find_by_params(params) == [@dataset]  
    end
    
    should 'find all datasets if empty keywords' do
      params = {:theme => {:id => nil}, :person => {:id => @person}, :keywords => ''}
      assert Dataset.find_by_params(params) == [@dataset]
    end
    
  end
end

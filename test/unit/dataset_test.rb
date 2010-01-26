require File.dirname(__FILE__) + '/../test_helper'

class DatasetTest < ActiveSupport::TestCase
  
   
  # context 'Temporal Extent' do
  #   setup do
  #     @dataset = Factory.create(:dataset, 
  #       :datatables  => [Factory.create(:datatable), 
  #                        Factory.create(:datatable, 
  #                        :object => "select now() - interval '2 days' as sample_date")])
  #   end
  #   
  #   should 'respond to within_interval' do
  #     assert @dataset.respond_to?('within_interval?')
  #   end
  #   
  #   should 'return true on within_interval today' do
  #     assert @dataset.within_interval?(Date.today, Date.today+1.day)
  #   end
  #   
  # end
  #   
  context "Finding Datasets" do
    
    setup do
      @person = Factory.create(:person)
      @dataset = Factory.create(:dataset,:keyword_list => 'earth,wind,fire', :people => [@person], 
                                :datatables=>[Factory.create(:datatable)])
      #future dataset
      Factory.create(:dataset,:keyword_list => 'fire', 
                  :datatables=>[Factory.create(:datatable, {:object => %q{select now() + '1 year' as sample_date}})])
      @unfound_dataset = Factory.create(:dataset, :keyword_list => 'wildfire')
      @theme = Factory.create(:theme, :datasets => [@dataset])
    end
    
    should 'respond to within_interval?' do
      assert @dataset.respond_to?('within_interval?')
    end
    
    should 'return yes for todays dataset' do
      assert @dataset.within_interval?(Date.today, Date.today)
    end
  
    should 'respond to find_by_date_interval' do
       assert Dataset.respond_to?('find_by_date_interval')
     end
     
    should 'find a dataset by todays date' do
      assert Dataset.find_by_date_interval(Date.today, Date.today) == [@dataset]
    end
    
    should 'find a dataset in the last month' do
      assert Dataset.find_by_date_interval(Date.today - 1.month, Date.today) == [@dataset]
    end
    
    should 'not find a dataset from last year' do
      assert Dataset.find_by_date_interval(Date.today - 1.year - 1.month, Date.today - 1.year) == []
    end
    
    should 'find a dataset if called only with the year' do
      assert Dataset.find_by_date_interval(Date.today.year, Date.today.year) == [@dataset]
    end
    
    should 'find a dataset if called with english names' do
      assert Dataset.find_by_date_interval('yesterday','tomorrow') == [@dataset]
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
    
    should 'respond to find_by_theme' do
      assert Dataset.find_by_theme(@theme)
    end
    
    should 'find one dataset by theme @theme' do
      assert Dataset.find_by_theme(@theme) == [@dataset]
    end
    
    should 'not find a dataset with a new theme' do
      new_theme = Factory.create(:theme)
      assert Dataset.find_by_theme(new_theme) == []
    end
    
    should 'respond to find_by_theme_keywords_person_date_interval' do
      assert Dataset.respond_to?('find_by_theme_person_keywords_date_interval')
    end
    
    should 'find one dataset if called with findable conditions' do
      assert Dataset.find_by_theme_person_keywords_date_interval(@theme, nil, nil,nil,nil) == [@dataset]
      assert Dataset.find_by_theme_person_keywords_date_interval(nil, @person, nil,nil,nil) == [@dataset]
      assert Dataset.find_by_theme_person_keywords_date_interval(nil, nil, 'wind',nil,nil) == [@dataset]     
      assert Dataset.find_by_theme_person_keywords_date_interval(nil,nil,nil,Date.today-1.month, Date.today) == [@dataset]
      assert Dataset.find_by_theme_person_keywords_date_interval(@theme,@person, 'wind',nil,nil) == [@dataset]
      assert Dataset.find_by_theme_person_keywords_date_interval(@theme,@person, 'wind',Date.today.year, Date.today.year) == [@dataset]
    end
    
    should 'not find a dataset if one of the conditions in not met' do
      assert Dataset.find_by_theme_person_keywords_date_interval(@theme, @person, 'wind', Date.today - 1.year, Date.today - 1.month) == []
      assert Dataset.find_by_theme_person_keywords_date_interval(nil, @person,'noise',nil,nil) == []
      assert Dataset.find_by_theme_person_keywords_date_interval(@theme, @person, 'noise', nil, nil) == []
    end
  end
end

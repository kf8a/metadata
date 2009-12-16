require File.dirname(__FILE__) + '/../test_helper'

class DatasetTest < ActiveSupport::TestCase
  
  Factory.define :datatable do |d|
     d.name 'KBS001_001'
     d.object 'select now() as sample_date'
     d.is_sql true
   end
  
  Factory.define :person do |p|
    p.sur_name 'bauer'
    p.given_name 'bill'
  end
  
  Factory.define :theme do |t|
    t.title  'Agronomic'
  end
  
  Factory.define :dataset do |d|
    d.title 'KBS001'
  end
  
  context 'Temporal Extent' do
    setup do
      @dataset = Factory.create(:dataset, 
        :datatables  => [Factory.create(:datatable), 
                         Factory.create(:datatable, 
                         :object => "select now() - interval '2 days' as sample_date")])
    end
    
    should 'respond to within_interval' do
      assert @dataset.respond_to?('within_interval?')
    end
    
    should 'return true on within_interval today' do
      assert @dataset.within_interval?(Date.today, Date.today+1.day)
    end
    
  end
  
  # context "Finding Datasets" do
  #   
  #   setup do
  #     @person = Factory.create(:person)
  #     @dataset = Factory.create(:dataset,:keyword_list => 'earth,wind', :people => [@person], 
  #                               :datatables=>[Factory.create(:datatable)])
  #     @unfound_dataset = Factory.create(:dataset, :keyword_list => 'wildfire')
  #     @theme = Factory.create(:theme, :datasets => [@dataset])
  #   end
  # 
  #   should 'respond to find_by_date_interval' do
  #     assert Dataset.find_by_date_interval(Time.now, Time.now - 1.year)
  #   end
  #   
  #   should 'find a dataset by todays date' do
  #     assert Dataset.find_by_date_interval(Date.today, Date.today).size == 1
  #   end
  #   
  #   should 'respond to find_by_keywords' do
  #     assert Dataset.find_by_keywords('earth,wind,fire')
  #   end
  #   
  #   should 'find one dataset by keyword earth' do
  #     assert Dataset.find_by_keywords('earth').size == 1
  #     assert Dataset.find_by_keywords('earth') == [@dataset]
  #   end
  #   
  #   should 'handle more than one keyword' do
  #     assert Dataset.find_by_keywords('earth,wind') == [@dataset]
  #   end
  #   
  #   should 'not find a dataset by a wrong keyword' do
  #     assert Dataset.find_by_keywords('fire') == []
  #   end
  #   
  #   should 'respond to find_by_person' do
  #     assert Dataset.find_by_person(Person.find(:first))
  #   end
  #   
  #   should 'find a dataset by person_id' do
  #     assert Dataset.find_by_person(@person).size == 1
  #     assert Dataset.find_by_person(@person) == [@dataset]
  #   end
  #   
  #   should 'not find a dataset by wrong person_id' do
  #     assert Dataset.find_by_person(5) == []
  #   end
  #   
  #   should 'respond to find_by_theme' do
  #     assert Dataset.find_by_theme(@theme)
  #   end
  #   
  #   should 'find one dataset by theme @theme' do
  #     assert Dataset.find_by_theme(@theme).size == 1
  #     assert Dataset.find_by_theme(@theme) == [@dataset]
  #   end
  #   
  #   should 'not find a dataset with a new theme' do
  #     new_theme = Factory.create(:theme)
  #     assert Dataset.find_by_theme(new_theme) == []
  #   end
  #   
  #   should 'respond to find_by_theme_keywords_person_date' do
  #     assert Dataset.find_by_theme_person_keywords_date(@theme, @person, 'fire',Date.today)
  #   end
  #   
  #   should 'find one dataset if called with findable words' do
  #     assert Dataset.find_by_theme_person_keywords_date(@theme, nil, nil,nil) == [@dataset]
  #     assert Dataset.find_by_theme_person_keywords_date(nil, @person, nil,nil) == [@dataset]
  #     assert Dataset.find_by_theme_person_keywords_date(nil, nil, 'wind',nil) == [@dataset]
  #     
  #   end
  #   
  # end
end

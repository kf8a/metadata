require File.dirname(__FILE__) + '/../test_helper'

class DatatableTest < ActiveSupport::TestCase
  
  should_belong_to :theme
  should_belong_to :core_area
  should_belong_to :dataset
  
  should_validate_presence_of :title
    
  context 'datatable' do
    setup do
      @datatable = Factory.create(:datatable)
    end
    
    should 'respond to temporal_extent' do
      assert @datatable.respond_to?('temporal_extent')
    end
    
    should 'respond_to has_data_in_interval?' do
      assert @datatable.respond_to?('within_interval?')
    end
    
    should 'respond to update_temporal_extent' do
      assert @datatable.respond_to?('update_temporal_extent')
    end
  end
  
    
  context 'datatable with sample_date' do
    setup do
      @datatable = Factory.create(:datatable)
      @old_data = Factory.create(:datatable, :object => %q{select now() - interval '3 year' as sample_date})
    end
    
    
    should 'return true if interval includes today' do
     assert @datatable.within_interval?(Date.today, Date.today + 1.day)
    end
    
    should 'return false if the interval is later than the data times' do
      assert !@datatable.within_interval?(Date.today + 1.day, Date.today + 4.day)
    end
    
    should 'return false if the interval is earlier than the data times' do
      assert !@datatable.within_interval?(Date.today - 4.day, Date.today - 2.day)
    end
         
    
    should 'have the correct temporal extent' do
      dates = @datatable.temporal_extent
      assert dates[:begin_date] == Date.today
      assert dates[:end_date] == Date.today
      
      dates = @old_data.temporal_extent
      assert dates[:begin_date] == Date.today - 3.years
      assert dates[:end_date] == Date.today - 3.years
    end
    
    should 'cache the temporal extent' do
      assert @datatable.begin_date.nil?
      assert @datatable.end_date.nil?
      @datatable.update_temporal_extent
      assert @datatable.begin_date == Date.today
      assert @datatable.end_date == Date.today
      
      assert @old_data.begin_date.nil?
      assert @old_data.end_date.nil?
      @old_data.update_temporal_extent
      assert @old_data.begin_date == Date.today - 3.years
      assert @old_data.end_date == Date.today - 3.years
    end
    
  end

  context 'datatable with range of dates' do
    setup do
      @datatable = Factory.create(:datatable, :object => %q{select current_date + (random() * n)::integer as sample_date from generate_series(0,11) n})
    end
    
    should 'have the begin_date before the end_date' do
      dates = @datatable.temporal_extent
      assert dates[:begin_date] < dates[:end_date]
    end
  end
  
  context 'datatable without sample_date' do
    setup do
      @datatable = Factory.create(:datatable)
      @datatable.object = 'select 1 as treatment'
    end
    
    should 'return false for within_interval?' do
      assert !@datatable.within_interval?(Date.today + 1.day, Date.today + 4.day)
    end
    
    should 'return nils for temporal_extent' do
      dates = @datatable.temporal_extent
      assert dates[:begin_date].nil?
      assert dates[:end_date].nil?
    end
    
  end
  
  context 'datatable with different date representations' do
    setup do 
      obs_date = Factory.create(:datatable, :object => %q{select current_date as obs_date})
      datetime = Factory.create(:datatable, :object => %q{select current_date as datetime})
      date = Factory.create(:datatable, :object => %q{select current_date as date})
      @date_representations = [obs_date, datetime, date]
    end
    
    should 'return true if interval includes today' do
      @date_representations.each do |date_representation|
        assert date_representation.within_interval?(Date.today, Date.today + 1.day)
      end
    end
    
    should 'return false if the interval is later than the data times' do
      @date_representations.each do |date_representation|
        assert !date_representation.within_interval?(Date.today + 1.day, Date.today + 4.day)
      end
    end
    
    should 'return false if the interval is earlier than the data times' do
      @date_representations.each do |date_representation|
        assert !date_representation.within_interval?(Date.today - 4.day, Date.today - 2.day)
      end
    end
         
    
    should 'have the correct temporal extent' do
      @date_representations.each do |date_representation|     
        dates = date_representation.temporal_extent
        assert dates[:begin_date] == Date.today
        assert dates[:end_date] == Date.today
      end
    end
    
    should 'cache the temporal extent' do
      @date_representations.each do |date_representation|
        date_representation.update_temporal_extent
        assert date_representation.begin_date == Date.today
        assert date_representation.end_date == Date.today
      end
    end
  end
  
  context 'eml generation' do
    setup do 
      @person = Factory.create(:person)
      dataset = Factory.create(:dataset, :people=>[@person])
      @datatable = Factory.create(:datatable, :dataset => dataset)
    end
    
    should 'return respond to to_eml' do
      assert @datatable.respond_to?('to_eml')
    end
    
    should 'return an eml datatable fragment' do
      eml = @datatable.to_eml
      assert eml.to_s =~ /datatable/
    end
  end
  
  context 'finding datatables' do
    setup do 
      @person = Factory.create(:person)
      @theme = Factory.create(:theme)
      @study = Factory.create(:study)
      dataset = Factory.create(:dataset, :people=>[@person], :studies => [@study])
      
      @datatable = Factory.create(:datatable, :dataset=> dataset, 
        :keyword_list => 'earth,wind,fire', :theme => @theme, :on_web => true)
        
      @datatable.update_temporal_extent
        
      @unfound_datatable = Factory.create(:datatable, :dataset => Factory.create(:dataset),
          :keyword_list => 'wildfire', :on_web => true)
      @unfound_study = Factory.create(:study)
      @unfound_datatable.dataset.studies << @unfound_study
      
    end
    
    should 'respond to find_by_keywords' do
      assert Datatable.respond_to?('find_by_keywords')
    end

    should 'find one datatable by keyword earth' do
      assert Datatable.find_by_keywords('earth') == [@datatable]
    end

    should 'handle more than one keyword' do
      assert Datatable.find_by_keywords('earth,wind') == [@datatable]
    end

    should 'not find a datatable by a wrong keyword' do
      assert Datatable.find_by_keywords('noise') == []
    end
    
    should 'find all datatables with empty keyword' do
      assert Datatable.find_by_keywords('').include?(@datatable)
      assert Datatable.find_by_keywords('').include?(@unfound_datatable)
    end
    
    should 'respond to find_by_person' do
      assert Datatable.respond_to?('find_by_person')
    end
       
    should 'find a datatable by person_id' do
      assert Datatable.find_by_person(@person) == [@datatable]
    end
    
    should 'not find a datatable by wrong person_id' do
      assert Datatable.find_by_person(5) == []
    end
       
    should 'not find a datatable with an empty person' do
      assert Datatable.find_by_person('') == []
    end
    
    # year
    should 'respond to find_by_year' do
       assert Datatable.respond_to?('find_by_year')
     end
         
    should 'not find a datatable from last year' do
      assert Datatable.find_by_year(Date.today - 1.year - 1.month, Date.today - 1.year - 1.day) == []
    end
    
    should 'find a datatable if called with the year' do
      assert Datatable.find_by_year(Date.today.year, Date.today.year) == [@datatable]
    end
    
       
    # themes
    should 'respond to find_by_theme' do
      assert Datatable.find_by_theme(@theme)
    end
    
    should 'find one datatable by theme @theme' do
      assert Datatable.find_by_theme(@theme) == [@datatable]
    end
    
    should 'find the datatable by theme id' do
      assert Datatable.find_by_theme(@theme.id) == [@datatable]
      assert Datatable.find_by_theme(@theme.id.to_s) == [@datatable]
    end
    
    should 'not find a datatable with a new theme' do
      new_theme = Factory.create(:theme)
      assert Datatable.find_by_theme(new_theme) == []
    end
    
    should 'not find a datatable with an empty string for theme' do
      assert Datatable.find_by_theme('') == []
    end

    # studies
    should 'respond to find_by_study' do
      assert Datatable.respond_to?('find_by_study') 
    end
    
    should 'find the right datatable with study' do
      assert Datatable.find_by_study(@study) == [@datatable]
      assert Datatable.find_by_study(@study.id) == [@datatable]
      assert Datatable.find_by_study(@study.id.to_s) == [@datatable]
    end
    
    should 'not find the wrong datatable with study' do
      new_study = Factory.create(:study)
      assert Datatable.find_by_study == []
      assert Datatable.find_by_study(@unfound_study) == [@unfound_datatable]
      assert Datatable.find_by_study(new_study) == []
      assert Datatable.find_by_study(new_study.id) == []
      assert Datatable.find_by_study(new_study.id.to_s) == []
    end
    
    # params
    should 'respond to find_by_params' do
      assert Datatable.respond_to?('find_by_params')
    end
    
    should 'find one datatable if called with one findable parameter' do
      params = {:theme => {:id => @theme.id.to_s}}
      assert Datatable.find_by_params(params) == [@datatable]
      params = {:person => {:id => @person}}
      assert Datatable.find_by_params(params) == [@datatable]
      params = {:keywords => 'wind'}
      assert Datatable.find_by_params(params) == [@datatable]
      params = {:study => {:id => @study.id}}
      assert Datatable.find_by_params(params) == [@datatable]
      params = {:date => {:syear => Date.today.year, :eyear => Date.today.year}}
      assert Datatable.find_by_params(params) == [@datatable]     
    end
    
    should 'not find datatable if called with  wrong theme' do
      t = Factory.create(:theme)
      params = {:theme => {:id => t.id}}
      assert Datatable.find_by_params(params) == []
    end
    
    should 'not find datatable if called with wrong person' do
      p = Factory.create(:person)
      params = {:person => {:id  => p.id}}
      assert Datatable.find_by_params(params) == []
    end
    
    should 'find one datatable if called with multiple findable parameters' do
      params = {:theme => {:id => @theme.id}, :person => {:id => @person.id}}
      assert Datatable.find_by_params(params) == [@datatable]
      params = {:theme => {:id => @theme}, :keywords => 'wind'}
      assert Datatable.find_by_params(params) == [@datatable]
      params = {:study => {:id => @study}, :theme => {:id => ''}, :person => {:id => ''},
          :date => {:syear => Date.today.year, :eyear => Date.today.year + 3}}
      assert Datatable.find_by_params(params) == [@datatable]
      params = params = {:study => {:id => nil}, :theme => {:id => ''}, :person => {:id => ''},
          :date => {:syear => Date.today.year, :eyear => Date.today.year + 3},
          :keywords => 'earth'}
      assert Datatable.find_by_params(params) == [@datatable]
    end
    
    should 'find one datatable if a parameter is empty' do    
      params = {:theme => {:id => ''}, :person => {:id => @person}}
      assert Datatable.find_by_params(params) == [@datatable]
      
      params = {:theme => {:id => nil}, :person => {:id => @person}}
      assert Datatable.find_by_params(params) == [@datatable]  
    end
    
    should 'find all datatables if empty keywords' do
      params = {:theme => {:id => nil}, :person => {:id => @person}, :keywords => ''}
      assert Datatable.find_by_params(params).include?(@datatable)
    end


  end
end

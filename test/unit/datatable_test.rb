require File.expand_path('../../test_helper',__FILE__) 

class DatatableTest < ActiveSupport::TestCase
  
  should belong_to                :core_area
  should belong_to                :dataset
  should have_many                :data_contributions
  should have_many                :owners
  should have_many                :ownerships
  should have_many                :permissions
  should have_and_belong_to_many  :protocols
  should belong_to                :study
  should belong_to                :theme
  should have_many                :variates
    
  should validate_presence_of :title
  should validate_presence_of :dataset
#  should validate_presence_of :study
    
  context 'datatable' do
    setup do
      @datatable = Factory :datatable
      assert_valid @datatable
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
    
    should 'respond to events' do
      assert @datatable.respond_to?('events')
    end
    
    should 'return events as a string' do
      assert_kind_of String, @datatable.events
    end
    
    should 'respond to study' do
      assert @datatable.respond_to?('study')
    end
  
  end
  
  context 'datatable personnel' do
    setup do
      dataset = Factory :dataset
      @datatable = Factory :datatable, :dataset => dataset
    end
    
    should 'be able to add contributors' do
      assert @datatable.data_contributions << [Factory.create(:data_contribution, :datatable => @datatable)]
      assert @datatable.datatable_personnel
    end
    
  end
  
  context 'datatable with and without sponsors' do
    setup do 
      sponsor = Factory.create :sponsor, :data_use_statement => 'Use it', :name => 'GLBRC'
      dataset_with_sponsor = Factory :dataset, :sponsor => sponsor
      dataset_without_sponsor = Factory :dataset, :sponsor => nil
      @datatable = Factory :datatable, :dataset => dataset_with_sponsor
      @datatable_without_sponsor = Factory :datatable, :dataset => dataset_without_sponsor
    end
    
    should 'retrieve data access statement' do
      assert @datatable.data_access_statement                 =~ /Use it/
      assert @datatable_without_sponsor.data_access_statement == ''    
    end
  end
  
  context 'a datatable with an event query' do
    setup do
      @datatable = Factory :datatable, :object=>'select now()'
    end
    
    should 'return a an array of events'
    
  end
  
  context 'datatable without owners and permissions' do
    setup do 
      @anonymous_user     = nil
      @unauthorized_user  = Factory :user, :email => 'unauthorized@person.com'
      @admin              = Factory :user, :email => 'admin@person.com', :role => 'admin'
      
      @unrestricted = Factory  :datatable
      
      sponsor = Factory :sponsor, :data_restricted => true
      dataset = Factory :dataset, :sponsor => sponsor
      @restricted = Factory :datatable, 
        :dataset    => dataset
    end
    
    should 'tell if it needs to be restricted at all' do
      assert !@unrestricted.restricted?
      assert  @restricted.restricted?
    end
     
    should 'allow restrict datatables to be permitted' do
      assert !@restricted.permitted?(@anonymous_user)
      assert !@restricted.permitted?(@unauthorized_user)
      assert !@restricted.permitted?(@admin)
    end

    should 'allow anyone to download unrestricted datatables' do
      assert @unrestricted.can_be_downloaded_by?(@anonymous_user)
      assert @unrestricted.can_be_downloaded_by?(@unauthorized_user)
      assert @unrestricted.can_be_downloaded_by?(@admin)
    end

    should 'only allow authorized users to download restricted datatables' do
      assert !@restricted.can_be_downloaded_by?(@anonymous_user)
      assert !@restricted.can_be_downloaded_by?(@unauthorized_user)
      assert  @restricted.can_be_downloaded_by?(@admin)
    end
   
  end
  
  context 'using datatable permissions' do
    setup do
      sponsor = Factory :sponsor, :data_restricted => true
      dataset = Factory :dataset, :sponsor => sponsor
      
      @anonymous_user     = nil
      @unauthorized_user  = Factory :user, :email => 'unauthorized@person.com'
      @authorized_user    = Factory :user, :email => 'authorized@person.com'
      @owner              = Factory :user, :email => 'owner@person.com'
      @admin              = Factory :user, :email => 'admin@person.com', :role => 'admin'
      @member             = Factory :user, :email => 'member@person.com', :sponsors => [sponsor]
            
      @unrestricted = Factory  :datatable
            
      @restricted = Factory :datatable, 
        :dataset    => dataset,
        :owners => [@owner]
      
      Factory :permission, 
        :datatable  => @restricted,
        :user       => @authorized_user,
        :owner      => @owner
    end
    
    should 'tell if it needs to be restricted at all' do
      assert !@unrestricted.restricted?
      assert @restricted.restricted?
    end
    
    should 'allow anyone to download unrestricted datatables' do
      assert @unrestricted.can_be_downloaded_by?(@anonymous_user)
      assert @unrestricted.can_be_downloaded_by?(@unauthorized_user)
      assert @unrestricted.can_be_downloaded_by?(@authorized_user)
      assert @unrestricted.can_be_downloaded_by?(@admin)
      assert @unrestricted.can_be_downloaded_by?(@member)
    end
    
    should 'only allow authorized users to download restricted datatables' do
      assert !@restricted.can_be_downloaded_by?(@anonymous_user)
      assert !@restricted.can_be_downloaded_by?(@unauthorized_user)
      assert  @restricted.can_be_downloaded_by?(@authorized_user)
      assert  @restricted.can_be_downloaded_by?(@admin)
      assert  @restricted.can_be_downloaded_by?(@member)
    end
    
    should 'authorized table should have the right owner' do
      assert @restricted.owners.size == 1
      assert @restricted.owners.include?(@owner)
    end 
  
  end
  
  context 'setting datatable permissions' do
    setup do
      @owner  = Factory :user, :email => 'owner@person.com'
      @user   = Factory :user, :email => 'user@person.com'
      @other  = Factory :user, :email => 'other@person.com'
      
      sponsor     = Factory :sponsor, :data_restricted => true
      dataset     = Factory :dataset, :sponsor => sponsor
      @datatable  = Factory :datatable, :owners => [@owner]
    end
    
    #TODO is there anything to test here?
        
  end
    
  context 'datatable with sample_date' do
    setup do
      @datatable = Factory.create(:datatable, :object => %q{select now() as sample_date} )
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
      obs_date = Factory.create(:datatable, :object => %q{select current_date at time zone 'America/New_York' as obs_date})
      datetime = Factory.create(:datatable, :object => %q{select current_date at time zone 'America/New_York' as datetime})
      date = Factory.create(:datatable, :object => %q{select current_date at time zone 'America/New_York' as date})
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

  context 'datatable with year' do
    setup do 
      @year = Factory.create(:datatable, :object => "select #{Time.now.year} as year")
    end

    should 'return true if interval includes today' do
        assert @year.within_interval?(Date.today - 1.year, Date.today + 1.day)
    end
    
    should 'return false if the interval is later than the data times' do
        assert !@year.within_interval?(Date.today + 1.day, Date.today + 4.day)
    end
    
    should 'return false if the interval is earlier than the data times' do
        assert !@year.within_interval?(Date.today - 4.year, Date.today - 2.year)
    end
         
    
    should 'have the correct temporal extent' do
        dates = @year.temporal_extent
        assert dates[:begin_date].year == Date.today.year
        assert dates[:end_date].year == Date.today.year
    end
    
    should 'cache the temporal extent' do
        @year.update_temporal_extent
        assert @year.begin_date.year == Date.today.year
        assert @year.end_date.year == Date.today.year
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
  
  context 'datatable formats' do
    setup do 
      dataset = Factory.create(:dataset)
      @datatable = Factory.create(:datatable, :dataset => dataset, :object=>"select now() as a, '1' as b")
      @datatable.variates << [Variate.new(:name => 'a'), Variate.new(:name => 'b')]
    end

    context 'climbdb format' do

      should 'respond to to_climdb' do
        assert @datatable.respond_to?('to_climdb')
      end

      context 'return a climdb formatted document' do

        setup do
          @doc = CSV.parse(@datatable.to_climdb)
        end

        should 'have the first line start with a bang !' do
          assert @doc[0].join(',') =~ /^!/
        end

      end

    end

    context 'csv format' do
      
      should 'respond to to_csv' do
        assert @datatable.respond_to?('to_csv')
      end
      
      should 'return a csv formatted document' do
        assert CSV.parse(@datatable.to_csv)
      end
      
      should 'return the data in the right order' do
        assert_equal '1', CSV.parse(@datatable.to_csv)[1][0]
      end
       
    end
    
    context 'xls format' do
      
      should 'respond to to_xls' do
        assert @datatable.respond_to?('to_xls')
      end
      
    end
    
    context 'ods format' do
      
      should 'respond to to_ods' do
        assert @datatable.respond_to?('to_ods')
        assert @datatable.to_ods
      end
      
    end
  end
  
end

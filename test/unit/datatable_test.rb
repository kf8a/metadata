require File.expand_path('../../test_helper',__FILE__)

class DatatableTest < ActiveSupport::TestCase

  should have_one                 :collection
  should belong_to                :core_area
  should belong_to                :dataset
  should have_many                :data_contributions
  should have_many                :owners
  should have_many                :ownerships
  should have_many                :people
  should have_many                :permission_requests
  should have_many                :permissions
  should have_and_belong_to_many  :protocols
  should have_many                :requesters
  should belong_to                :study
  should belong_to                :theme
  should have_many                :variates

  should validate_presence_of :title
  should validate_presence_of :dataset

  context 'datatable' do
    setup do
      @datatable = Factory :datatable
      assert_valid @datatable
    end

    context 'which has a title and name' do
      setup do
        @datatable.title = 'Cool Title'
        @datatable.name = 'Excellent Name'
      end

      should 'respond to #to_label with the title and name' do
        assert_equal 'Cool Title (Excellent Name)', @datatable.to_label
      end
    end

    context 'which has datatable personnel' do
      setup do
        @person1 = Factory.create(:person, :sur_name => 'Datatableman')
        @person2 = Factory.create(:person, :sur_name => 'Datatablewoman')
        @datatable.stubs(:datatable_personnel).returns([@person1, @person2])
      end

      should 'return those personnel on #personnel' do
        assert_equal [@person1, @person2], @datatable.personnel
      end
    end

    context 'which has no datatable personnel but does have dataset personnel' do
      setup do
        @person1 = Factory.create(:person, :sur_name => 'Datatableman')
        @person2 = Factory.create(:person, :sur_name => 'Datatablewoman')
        @datatable.stubs(:datatable_personnel).returns([])
        @datatable.stubs(:dataset_personnel).returns([@person1, @person2])
      end

      should 'return the dataset personnel' do
        assert_equal [@person1, @person2], @datatable.personnel
      end
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
      assert_respond_to @datatable, 'study'
    end

  end

  context 'datatable personnel' do
    setup do
      dataset = Factory :dataset
      @datatable = Factory :datatable, :dataset => dataset
    end

    should 'be able to add contributors' do
      person = Factory.create(:person)
      assert @datatable.data_contributions << [Factory.create(:data_contribution, :datatable => @datatable, :person => person)]
      different_role = Factory.create(:role, :name => 'AnotherRole')
      @datatable.data_contributions << [Factory.create(:data_contribution, :datatable => @datatable, :person => person, :role => different_role)]
      another_person = Factory.create(:person, :sur_name => 'Testerman')
      @datatable.data_contributions << [Factory.create(:data_contribution, :datatable => @datatable, :person => another_person)]
      assert_equal 2, @datatable.datatable_personnel[person].count
      assert_equal ["Emeritus Investigators", "AnotherRole"], @datatable.datatable_personnel[person]
      assert_equal ["Emeritus Investigators"], @datatable.datatable_personnel[another_person]
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
      @denied_user        = Factory :user, :email => 'denied@perso.com'

      @unrestricted = Factory  :datatable

      @restricted = Factory :datatable,
        :dataset    => dataset,
        :owners => [@owner]

      Factory :permission,
        :datatable  => @restricted,
        :user       => @authorized_user,
        :owner      => @owner

      Factory :permission,
        :datatable  => @restricted,
        :user       => @denied_user,
        :owner      => @owner,
        :decision   => 'denied'
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
      assert @unrestricted.can_be_downloaded_by?(@denied_user)
    end

    should 'only allow authorized users to download restricted datatables' do
      assert !@restricted.can_be_downloaded_by?(@anonymous_user)
      assert !@restricted.can_be_downloaded_by?(@unauthorized_user)
      assert  @restricted.can_be_downloaded_by?(@authorized_user)
      assert  @restricted.can_be_downloaded_by?(@admin)
      assert !@restricted.can_be_downloaded_by?(@member)
      assert  @restricted.can_be_downloaded_by?(@owner)
      assert !@restricted.can_be_downloaded_by?(@denied_user)
    end

    should 'return the owner that denied user on #deniers_of' do
      assert_equal [@owner], @restricted.deniers_of(@denied_user)
      assert_equal [], @restricted.deniers_of(@authorized_user)
    end

    should 'authorized table should have the right owner' do
      assert @restricted.owners.size == 1
      assert @restricted.owners.include?(@owner)
    end
  end

  context 'A datatable with permission requests' do
    setup do
      @owner  = Factory :user, :email => 'owner@person.com'
      @user   = Factory :user, :email => 'user@person.com'
      @other  = Factory :user, :email => 'other@person.com'
      @permitted_user = Factory :user, :email => 'permitted@person.com'

      sponsor     = Factory :sponsor, :data_restricted => true
      dataset     = Factory :dataset, :sponsor => sponsor
      @datatable  = Factory :datatable, :owners => [@owner]

      Factory.create(:permission_request, :user => @user, :datatable => @datatable)
      Factory.create(:permission_request, :user => @permitted_user, :datatable => @datatable)
      Factory.create(:permission, :owner => @owner, :datatable => @datatable, :user => @permitted_user)
    end

    context '#pending_requesters' do
      setup do
        @result = @datatable.pending_requesters
      end

      should 'include the users of those permission requests' do
        assert @result.include?(@user)
      end

      should 'not include users who are already permitted' do
        assert !@result.include?(@permitted_user)
      end
    end

    context '#requested_by?' do
      should 'be true for those who requested' do
        assert @datatable.requested_by?(@user)
        assert @datatable.requested_by?(@permitted_user)
      end

      should 'be false for others' do
        assert !@datatable.requested_by?(@other)
      end
    end

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

    context '#title and years' do
      should 'just be title if no years.' do
        @datatable.begin_date = nil
        @datatable.end_date = nil
        assert_equal 'a really cool datatable', @datatable.title_and_years
      end

      should 'include only one year if end and begin are the same' do
        @datatable.begin_date = '2/12/2003'.to_date
        @datatable.end_date = '2/12/2003'.to_date
        assert_equal "a really cool datatable (2003)", @datatable.title_and_years
      end

      should 'include both years if end and begin are different' do
        @datatable.begin_date = '2/12/2003'.to_date
        @datatable.end_date = '2/12/2004'.to_date
        assert_equal "a really cool datatable (2003 to 2004)", @datatable.title_and_years
      end
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
      obs_date = Factory.create(:datatable, :object => %Q{select date '#{Date.today}' as obs_date})
      datetime = Factory.create(:datatable, :object => %Q{select date '#{Date.today}'as datetime})
      date = Factory.create(:datatable, :object => %Q{select date '#{Date.today}' as date})
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

  context 'datatable formats' do
    setup do
      dataset = Factory.create(:dataset)
      @datatable = Factory.create(:datatable, :dataset => dataset, :object=>"select now() as a, '1' as b", :number_of_released_records => 1)
      @datatable.variates << [Variate.new(:name => 'a'), Variate.new(:name => 'b')]
    end

    context 'eml format' do
      setup  do
        @datatable.protocols << Factory.create(:protocol)
        @eml = @datatable.to_eml
      end

      should 'return respond to to_eml' do
        assert @datatable.respond_to?('to_eml')
      end

      should 'return an eml datatable fragment' do
        assert @eml.to_s =~ /datatable/
      end

      context '#to_eml' do
        setup do
          @to_eml = Nokogiri::XML(@datatable.to_eml)
        end

        should 'include the datatable id' do
          assert_equal 1, @to_eml.css("dataTable##{@datatable.name}").count
        end

        should 'include an entityName element' do
          assert_equal 'a really cool datatable', @to_eml.at_css('dataTable entityName').text
        end

        should 'include an entityDescription element' do
          assert_equal 'This is a datatable', @to_eml.at_css('dataTable entityDescription').text
        end
      end
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
        assert CSV.parse(@datatable.raw_csv)
      end

      should 'return the data in the right order' do
        data = CSV.parse(@datatable.raw_csv)
        b_column = data[0].index("b")
        assert_equal '1', data[1][b_column]
      end

      context 'with comment' do
        setup  {@datatable.comments = "something\nand something else"}

        should 'return a commented out version of the comment' do
          assert_equal "#something\n#and something else\n", @datatable.data_comments
        end
      end
    end

  end

end



# == Schema Information
#
# Table name: datatables
#
#  id                         :integer         not null, primary key
#  name                       :string(255)
#  title                      :string(255)
#  comments                   :text
#  dataset_id                 :integer
#  data_url                   :string(255)
#  connection_url             :string(255)
#  driver                     :string(255)
#  is_restricted              :boolean
#  description                :text
#  object                     :text
#  metadata_url               :string(255)
#  is_sql                     :boolean
#  update_frequency_days      :integer
#  last_updated_on            :date
#  access_statement           :text
#  excerpt_limit              :integer
#  begin_date                 :date
#  end_date                   :date
#  on_web                     :boolean         default(TRUE)
#  theme_id                   :integer
#  core_area_id               :integer
#  weight                     :integer         default(100)
#  study_id                   :integer
#  created_at                 :datetime
#  updated_at                 :datetime
#  is_secondary               :boolean         default(FALSE)
#  is_utf_8                   :boolean         default(FALSE)
#  metadata_only              :boolean         default(FALSE)
#  summary_graph              :text
#  event_query                :text
#  deprecated_in_fovor_of     :integer
#  deprecation_notice         :text
#  number_of_released_records :integer
#


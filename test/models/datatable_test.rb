require File.expand_path('../../test_helper', __FILE__)

class DatatableTest < ActiveSupport::TestCase
  should have_one                 :collection
  should have_and_belong_to_many  :core_areas
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
      @datatable = FactoryBot.build :datatable
      assert(@datatable.valid?)
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
        @person1 = FactoryBot.create(:person, sur_name: 'Datatableman')
        @person2 = FactoryBot.create(:person, sur_name: 'Datatablewoman')
        @role = FactoryBot.create(:role)
        @datatable.data_contributions << DataContribution.create(person: @person1, role: @role)
        @datatable.data_contributions << DataContribution.create(person: @person2, role: @role)
      end

      should 'return those personnel on #personnel' do
        # TODO: change test to reflect current usage
        # assert_equal [@person1, @person2], @datatable.personnel
      end
    end

    should 'respond_to has_data_in_interval?' do
      assert @datatable.respond_to?('within_interval?')
    end

    should 'respond to study' do
      assert_respond_to @datatable, 'study'
    end
  end

  context 'datatable personnel' do
    setup do
      dataset = FactoryBot.build :dataset
      @datatable = FactoryBot.build :datatable, dataset: dataset
    end

    should 'be able to add contributors' do
      person = FactoryBot.create(:person)
      assert @datatable.data_contributions << [FactoryBot.create(:data_contribution,
                                                                  datatable:
                                                                  @datatable, person: person)]
      different_role = FactoryBot.create(:role, name: 'AnotherRole')
      @datatable.data_contributions << [FactoryBot.create(:data_contribution,
                                                           datatable: @datatable,
                                                           person: person,
                                                           role: different_role)]
      another_person = FactoryBot.create(:person, sur_name: 'Testerman')
      @datatable.data_contributions << [FactoryBot.create(:data_contribution,
                                                           datatable: @datatable,
                                                           person: another_person)]
      assert_equal 2, @datatable.datatable_personnel[person].count
      assert_equal ['Emeritus Investigators', 'AnotherRole'], @datatable.datatable_personnel[person]
      assert_equal ['Emeritus Investigators'], @datatable.datatable_personnel[another_person]
    end
  end

  context 'datatable with and without sponsors' do
    setup do
      sponsor = FactoryBot.create :sponsor, data_use_statement: 'Use it', name: 'GLBRC'
      dataset_with_sponsor = FactoryBot.build :dataset, sponsor: sponsor
      dataset_without_sponsor = FactoryBot.build :dataset, sponsor: nil
      @datatable = FactoryBot.build :datatable, dataset: dataset_with_sponsor
      @datatable_without_sponsor = FactoryBot.build :datatable, dataset: dataset_without_sponsor
    end

  end

  context 'datatable without owners and permissions' do
    setup do
      @anonymous_user     = nil
      @unauthorized_user  = FactoryBot.build :user, email: 'unauthorized@person.com'
      @admin              = FactoryBot.build :user, email: 'admin@person.com', role: 'admin'

      @unrestricted = FactoryBot.build :datatable

      sponsor = FactoryBot.build :sponsor, data_restricted: true
      dataset = FactoryBot.build :dataset, sponsor: sponsor
      @restricted = FactoryBot.build :datatable, dataset: dataset
    end

    should 'tell if it needs to be restricted at all' do
      assert !@unrestricted.restricted_to_members?
      assert  @restricted.restricted_to_members?
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
      sponsor = FactoryBot.create :sponsor, data_restricted: true
      dataset = FactoryBot.create :dataset, sponsor: sponsor

      @anonymous_user     = nil
      @unauthorized_user  = FactoryBot.create :user, email: 'unauthorized@person.com'
      @authorized_user    = FactoryBot.create :user, email: 'authorized@person.com'
      @owner              = FactoryBot.create :user, email: 'owner@person.com'
      @admin              = FactoryBot.create :user, email: 'admin@person.com', role: 'admin'
      @member             = FactoryBot.create :user, email: 'member@person.com',
                                                      sponsors: [sponsor]
      @denied_user        = FactoryBot.create :user, email: 'denied@perso.com'

      @unrestricted = FactoryBot.create :datatable

      @restricted_to_members = FactoryBot.create :datatable, dataset: dataset
      @restricted_to_members.owners = [@owner]

      @restricted = FactoryBot.create :datatable, dataset: dataset, is_restricted: true
      @restricted.owners = [@owner]

      FactoryBot.create :permission, datatable: @restricted_to_members,
                                      user: @authorized_user,
                                      owner: @owner,
                                      decision: 'approved'

      FactoryBot.create :permission, datatable: @restricted_to_members,
                                      user: @denied_user,
                                      owner: @owner,
                                      decision: 'denied'

      FactoryBot.create :permission, datatable: @restricted,
                                      user:  @authorized_user,
                                      owner: @owner,
                                      decision: 'approved'
    end

    should 'tell if it needs to be restricted at all' do
      assert !@unrestricted.restricted_to_members?
      assert @restricted_to_members.restricted_to_members?
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
      assert !@restricted_to_members.can_be_downloaded_by?(@anonymous_user)
      assert !@restricted_to_members.can_be_downloaded_by?(@unauthorized_user)
      assert  @restricted_to_members.can_be_downloaded_by?(@authorized_user)
      assert  @restricted_to_members.can_be_downloaded_by?(@admin)
      assert  @restricted_to_members.can_be_downloaded_by?(@member)
      assert  @restricted_to_members.can_be_downloaded_by?(@owner)
      assert !@restricted_to_members.can_be_downloaded_by?(@denied_user)

      assert !@restricted.can_be_downloaded_by?(@anonoymous_user)
      assert !@restricted.can_be_downloaded_by?(@member)
      assert !@restricted.can_be_downloaded_by?(@denied_user)
      assert  @restricted.can_be_downloaded_by?(@admin)
      assert  @restricted.can_be_downloaded_by?(@owner)
      assert  @restricted.can_be_downloaded_by?(@authorized_user)
    end

    should 'return the owner that denied user on #deniers_of' do
      assert_equal [@owner], @restricted_to_members.deniers_of(@denied_user)
      assert_equal [], @restricted_to_members.deniers_of(@authorized_user)
    end

    should 'authorized table should have the right owner' do
      assert @restricted_to_members.owners.size == 1
      assert @restricted_to_members.owners.include?(@owner)
    end
  end

  context 'A datatable with permission requests' do
    setup do
      @owner  = FactoryBot.create :user, email: 'owner@person.com'
      @user   = FactoryBot.create :user, email: 'user@person.com'
      @other  = FactoryBot.create :user, email: 'other@person.com'
      @permitted_user = FactoryBot.create :user, email: 'permitted@person.com'

      sponsor     = FactoryBot.create :sponsor, data_restricted: true
      dataset     = FactoryBot.create :dataset, sponsor: sponsor
      @datatable  = FactoryBot.create :datatable, dataset: dataset
      @datatable.owners = [@owner]

      FactoryBot.create(:permission_request, user: @user,
                                              datatable: @datatable)
      FactoryBot.create(:permission_request, user: @permitted_user,
                                              datatable: @datatable)
      FactoryBot.create(:permission,
                         owner: @owner,
                         datatable: @datatable,
                         user: @permitted_user,
                         decision: 'approved')
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

  context 'getting unreleased data for qc purposes in the LTER sponsor' do
    setup do
      sponsor     = FactoryBot.build :sponsor, name: 'lter'
      dataset     = FactoryBot.build :dataset, sponsor: sponsor
      @datatable  = FactoryBot.build :datatable, dataset: dataset

      restricted_sponsor     = FactoryBot.build :sponsor, data_restricted: true
      restricted_dataset     = FactoryBot.build :dataset, sponsor: restricted_sponsor
      @restricted_datatable  = FactoryBot.build :datatable, dataset: restricted_dataset

      @anonymous_user     = nil
      @admin              = FactoryBot.build :user, email: 'admin@person.com', role: 'admin'
      @non_member         = FactoryBot.build :user, email: 'non_member@person.com'
      @member             = FactoryBot.build :user, email: 'member@person.com', sponsors: [sponsor]
    end

    should 'allow admins' do
      assert @datatable.can_be_qcd_by?(@admin)
    end

    should 'allow members' do
      assert @datatable.can_be_qcd_by?(@member)
    end

    should 'not allow anonymous users' do
      assert !@datatable.can_be_qcd_by?(@anonymous_user)
    end

    should 'not allow non members' do
      assert !@datatable.can_be_qcd_by?(@non_member)
    end

    should 'not allow outside datatables' do
      assert !@restricted_datatable.can_be_qcd_by?(@member)
      assert !@restricted_datatable.can_be_qcd_by?(@non_member)
      assert !@restricted_datatable.can_be_qcd_by?(@anonymous_user)
    end
  end

  context 'datatable with sample_date' do
    setup do
      @datatable = FactoryBot.create(:datatable, object: %q{select now() as sample_date})
      @old_data = FactoryBot.create(:datatable, object: %q{select now() - interval '3 year' as sample_date})
    end

    should 'return true if interval includes today' do
      assert @datatable.within_interval?(Time.zone.today, Time.zone.today + 1.day)
    end

    should 'return false if the interval is later than the data times' do
      assert !@datatable.within_interval?(Time.zone.today + 1.day, Time.zone.today + 4.days)
    end

    should 'return false if the interval is earlier than the data times' do
      assert !@datatable.within_interval?(Time.zone.today - 4.days, Time.zone.today - 2.days)
    end

    should 'have the correct temporal extent' do
      dates = @datatable.temporal_extent
      assert dates[:begin_date] == Time.zone.today
      assert dates[:end_date] == Time.zone.today

      dates = @old_data.temporal_extent
      assert dates[:begin_date] == Time.zone.today - 3.years
      assert dates[:end_date] == Time.zone.today - 3.years
    end

    should 'cache the temporal extent' do
      assert @datatable.begin_date.nil?
      assert @datatable.end_date.nil?
      @datatable.update_temporal_extent
      assert @datatable.begin_date == Time.zone.today
      assert @datatable.end_date == Time.zone.today

      assert @old_data.begin_date.nil?
      assert @old_data.end_date.nil?
      @old_data.update_temporal_extent
      assert @old_data.begin_date == Time.zone.today - 3.years
      assert @old_data.end_date == Time.zone.today - 3.years

      assert @old_data.dataset.initiated = Time.zone.today - 3.years
      assert @old_data.dataset.data_end_date = Time.zone.today - 3.years
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
        assert_equal 'a really cool datatable (2003)', @datatable.title_and_years
      end

      should 'include both years if end and begin are different' do
        @datatable.begin_date = '2/12/2003'.to_date
        @datatable.end_date = '2/12/2004'.to_date
        assert_equal 'a really cool datatable (2003 to 2004)',
          @datatable.title_and_years
      end

      should 'say to present if within the last 2 years' do
        started_on = (Time.now - 1.year).to_date
        @datatable.begin_date = started_on
        @datatable.end_date = Time.zone.today
        assert_equal "a really cool datatable (#{started_on.year} to present)",
                     @datatable.title_and_years
      end

      should 'say to present if within 2 years of the expected sample' do
        @datatable.begin_date = '2/12/2003'.to_date
        @datatable.end_date = '2/12/2004'.to_date
        @datatable.update_frequency_days = 24_000

        assert_equal('a really cool datatable (2003 to present)',
                     @datatable.title_and_years)
      end

      should 'give the end date if complted' do
        started_on = (Time.zone.today - 1.year).to_date
        @datatable.begin_date = started_on
        @datatable.end_date = Time.zone.today
        @datatable.complete!

        assert_equal "a really cool datatable (#{started_on.year} to #{Time.zone.today.year})",
                     @datatable.title_and_years
      end
    end
  end

  context 'datatable with range of dates' do
    setup do
      @datatable = FactoryBot.create(:datatable,
                                      object: %q{select current_date + (random() * n)::integer as sample_date from generate_series(0,11) n})
    end

    should 'have the begin_date before the end_date' do
      dates = @datatable.temporal_extent
      assert dates[:begin_date] < dates[:end_date]
    end
  end

  context 'datatable without sample_date' do
    setup do
      @datatable = FactoryBot.create(:datatable)
      @datatable.object = 'select 1 as treatment'
    end

    should 'return false for within_interval?' do
      assert !@datatable.within_interval?(Time.zone.today + 1.day,
                                          Time.zone.today + 4.days)
    end

    should 'return nils for temporal_extent' do
      dates = @datatable.temporal_extent
      assert dates[:begin_date].nil?
      assert dates[:end_date].nil?
    end
  end

  context 'datatable with different date representations' do
    setup do
      obs_date = FactoryBot.create(:datatable,
                                    object: %(select date '#{Time.zone.today}' as obs_date))
      datetime = FactoryBot.create(:datatable,
                                    object: %(select date '#{Time.zone.today}'as datetime))
      date = FactoryBot.create(:datatable,
                                object: %(select date '#{Time.zone.today}' as date))
      @date_representations = [obs_date, datetime, date]
    end

    should 'return true if interval includes today' do
      @date_representations.each do |date_representation|
        assert date_representation.within_interval?(Time.zone.today,
                                                    Time.zone.today + 1.day)
      end
    end

    should 'return false if the interval is later than the data times' do
      @date_representations.each do |date_representation|
        assert !date_representation.within_interval?(Time.zone.today + 1.day,
                                                     Time.zone.today + 4.days)
      end
    end

    should 'return false if the interval is earlier than the data times' do
      @date_representations.each do |date_representation|
        assert !date_representation.within_interval?(Time.zone.today - 4.days,
                                                     Time.zone.today - 2.days)
      end
    end

    should 'have the correct temporal extent' do
      @date_representations.each do |date_representation|
        dates = date_representation.temporal_extent
        assert dates[:begin_date] == Time.zone.today
        assert dates[:end_date] == Time.zone.today
      end
    end

    should 'cache the temporal extent' do
      @date_representations.each do |date_representation|
        date_representation.update_temporal_extent
        assert date_representation.begin_date == Time.zone.today
        assert date_representation.end_date == Time.zone.today
      end
    end
  end

  context 'datatable with year' do
    setup do
      @year = FactoryBot.build(:datatable,
                                object: "select #{Time.zone.today.year} as year")
    end

    should 'return true if interval includes today' do
      assert @year.within_interval?(Time.zone.today - 1.year, Time.zone.today + 1.day)
    end

    should 'return false if the interval is later than the data times' do
      assert !@year.within_interval?(Time.zone.today + 1.day, Time.zone.today + 4.days)
    end

    should 'return false if the interval is earlier than the data times' do
      assert !@year.within_interval?(Time.zone.today - 4.years, Time.zone.today - 2.years)
    end

    should 'have the correct temporal extent' do
      dates = @year.temporal_extent
      assert dates[:begin_date].year == Time.zone.today.year
      assert dates[:end_date].year == Time.zone.today.year
    end

    should 'cache the temporal extent' do
      @year.update_temporal_extent
      assert @year.begin_date.year == Time.zone.today.year
      assert @year.end_date.year == Time.zone.today.year
    end
  end

  context 'datatable formats' do
    setup do
      dataset = FactoryBot.create(:dataset)
      @datatable = FactoryBot.build(:datatable,
                                    dataset: dataset,
                                    object: "select now() as a, '1' as b",
                                    number_of_released_records: 1)
      @datatable.variates << [Variate.new(name: 'a'), Variate.new(name: 'b')]
    end

    context 'eml format' do
      setup do
        @datatable.protocols << FactoryBot.create(:protocol)
        @eml = @datatable.to_eml
      end

      should 'say that is it valid for eml' do
        assert @datatable.valid_for_eml?
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

        should 'include an entityName element' do
          assert_equal "Kellogg Biological Station LTER: a really cool datatable (#{@datatable.name})",
                        @to_eml.at_css('dataTable entityName').text
        end

        should 'include an entityDescription element' do
          assert @to_eml.at_css('dataTable entityDescription').text =~ /This is a datatable/
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
        data = CSV.parse(@datatable.approved_csv)
        b_column = data[0].index('b')
        assert_equal '1', data[2][b_column]
      end

      should 'return data even if the variate names are capitalized' do
        @datatable.variates = [Variate.new(name: 'a'), Variate.new(name: 'B')]
        @datatable.save
        data = CSV.parse(@datatable.approved_csv)
        b_column = data[0].index('B')
        assert_equal '1', data[2][b_column]
      end

      should 'return data if the query names are capitalized' do
        @datatable.object = %q{select now() as a, '1' as "B"}
        @datatable.variates = [Variate.new(name: 'a'), Variate.new(name: 'B')]

        @datatable.save
        data = CSV.parse(@datatable.approved_csv)
        b_column = data[0].index('B')
        assert_equal '1', data[2][b_column]
      end

      context 'with comment' do
        setup  { @datatable.comments = 'something\nand something else' }

        should 'return a commented out version of the comment' do
          assert_equal "#\n#        DATA TABLE CORRECTIONS AND COMMENTS\n#something\n#and something else\n#\n", @datatable.data_comments
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

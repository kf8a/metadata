FactoryGirl.define do

  #Independent factories#########
  factory :affiliation do
  end

  factory :author do
    seniority  1
  end

  factory :editor do
    seniority  1
  end

  factory :citation do
    website   Website.find_by_name('lter')
  end

  factory :article_citation do
  end

  factory :book_citation do
  end

  factory :citation_type do
  end

  factory :invite do
    sequence(:email) {|n| "person#{n}@example.com" }
  end

  factory :page do
  end

  factory :permission do
  end

  factory :permission_request do
  end

  factory :person do
    sur_name    'bauer'
    given_name  'bill'
    city        'hickory corners'
  end

  factory :project do
  end

  factory :publication do
    citation            'bogus data, brown and company'
    abstract            'something in here'
    year                2000
    publication_type_id 1
  end

  factory :publication_type do
  end

  factory :role_type do
  end

  factory :species do
  end

  factory :sponsor do
    name    'LTER'

    factory :restricted_sponsor do
      data_restricted   true
    end
  end

  factory :study do
    name    'LTER'
  end

  factory :study_url do
  end

  factory :treatment do
  end

  factory :unit do
  end

  factory :upload do
  end

  factory :template do
  end

  factory :theme do
    name  'Agronomic'
  end

  factory :variate do
    name              'date'
    description       'generic variate'
    measurement_scale 'dateTime'
  end

  factory :venue_type do
    name  'Venue Name'
  end

  factory :visualization do
    query        "select 1 as sample_date"
  end

  factory :website do
    name 'Name'
  end

  #Dependent factories##########

  factory :role do
    name 'Emeritus Investigators'

    factory :lter_role do
      role_type    { RoleType.find_by_name('lter') || FactoryGirl.create(:role_type, :name => 'lter') }
    end
  end

  sequence :dataset_text do |n|
    "uniquedataset#{n}"
  end

  factory :dataset do
    title     'KBS001'
    abstract  'some new dataset'
    dataset   { Factory.next(:dataset_text) }

    factory :restricted_dataset do |dataset|
      association :sponsor, :factory => :restricted_sponsor
    end
  end

  factory :protocol do
    name          'Proto1'
    version_tag   0
    dataset       { FactoryGirl.create(:dataset) }
  end

  sequence :name do |n|
    "KBS001_#{n}"
  end

  factory :datatable do
    name
    title         'a really cool datatable'
    object        "select 1 as sample_date"
    is_sql         true
    description   'This is a datatable'
    weight        100
    theme
    dataset
    variates      [FactoryGirl.create(:variate)]

    factory :public_datatable do
    end

    factory :protected_datatable do
      association :dataset, :factory => :restricted_dataset
    end

    factory :old_datatable do
      object   %q{select now() - interval '3 year' as sample_date}
    end
  end

  factory :ownership do
    datatable
    user
  end

  factory :data_contribution do
    person
    role
    datatable
  end

  factory :meeting do
    venue_type_id   1
  end

  factory :collection do
    datatable
  end

  factory :abstract do
    abstract  'A quick little discussion of the meeting.'
    meeting
  end
end

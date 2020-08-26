FactoryBot.define do
  # Independent factories#########
  factory :affiliation do
    role
    association :person
  end

  factory :author do
    seniority { 1 }
  end

  factory :citation_type do
  end

  factory :editor do
    seniority  { 1 }
  end

  factory :citation do
    website  { Website.find_by(name: 'lter') }
    authors  { [FactoryBot.build(:author)] }
    citation_type
  end

  factory :article_citation do
    website  { Website.find_by(name: 'lter') }
    authors  { [FactoryBot.build(:author)] }
    citation_type
  end

  factory :book_citation do
    website  { Website.find_by(name: 'lter') }
    authors  { [FactoryBot.build(:author)] }
    citation_type
  end

  factory :chapter_citation do
    website  { Website.find_by(name: 'lter') }
    authors  { [FactoryBot.build(:author)] }
    citation_type
  end

  factory :thesis_citation do
    website  { Website.find_by(name: 'lter') }
    authors  { [FactoryBot.build(:author)] }
    citation_type
  end

  factory :invite do
    sequence(:email) { |n| "person#{n}@example.com" }
  end

  factory :page do
  end

  factory :permission do
  end

  factory :permission_request do
  end

  sequence :person_sur_name do |n|
    "bauer #{n}"
  end

  factory :person do
    sur_name { FactoryBot.generate(:person_sur_name) }
    given_name { 'bill' }
    city { 'hickory corners' }
  end

  factory :project do
  end

  sequence :role_type_name do |n|
    "role #{n}"
  end

  factory :role_type do
    name { FactoryBot.generate(:role_type_name) }
  end

  factory :species do
  end

  factory :sponsor do
    name { 'LTER' }

    factory :restricted_sponsor do
      data_restricted { true }
    end
  end

  sequence :study_name do |n|
    "Study #{n}"
  end

  factory :study do
    name { FactoryBot.generate(:study_name) }
  end

  factory :study_url do
    association :study
    association :website
  end

  factory :treatment do
    association :study
  end

  factory :unit do
  end

  factory :upload do
  end

  factory :template do
  end

  factory :theme do
    name  { 'Agronomic' }
  end

  factory :variate do
    name  { 'date' }
    description { 'generic variate' }
    measurement_scale { 'dateTime' }
    date_format { 'YYYY-MM-DD' }
    unit
  end

  factory :venue_type do
    name  { 'Venue Name' }
  end

  factory :visualization do
    query  { 'select 1 as sample_date' }
  end

  sequence :website_name do |n|
    "website #{n}"
  end

  factory :website do
    name { FactoryBot.generate(:website_name) }
  end

  # Dependent factories##########

  factory :role do
    name { "Emeritus Investigators" }
    association :role_type

    factory :lter_role do
      role_type { RoleType.find_by(:name, 'lter') || FactoryBot.create(:role_type, name: 'lter') }
    end
  end

  sequence :dataset_text do |n|
    "uniquedataset#{n}"
  end

  factory :dataset do
    title     { 'KBS001' }
    version   { 0 }
    abstract  { 'some new dataset' }
    dataset   { FactoryBot.generate(:dataset_text) }
    sponsor   { FactoryBot.build(:sponsor) }

    factory :restricted_dataset do |_dataset|
      association :sponsor, factory: :restricted_sponsor
    end
  end

  factory :protocol do
    name          { 'Proto1' }
    version_tag   { 0 }
    dataset       { FactoryBot.build(:dataset) }
    # project { FactoryBot.build(:project) }
    # website { FactoryBot.build(:website) }
  end

  sequence :name do |n|
    "KBS001_#{n}"
  end

  factory :datatable do
    name
    title { 'a really cool datatable' }
    object { 'select now() as sample_date' }
    is_sql { true }
    description { 'This is a datatable' }
    weight { 100 }
    association :theme
    association :study
    dataset
    variates { [FactoryBot.create(:variate)] }

    factory :public_datatable do
    end

    factory :protected_datatable do
      association :dataset, factory: :restricted_dataset
    end

    factory :old_datatable do
      object { %{select now() - interval '3 year' as sample_date} }
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
    venue_type_id { 1 }
    date { Time.zone.today }
  end

  factory :collection do
    datatable
  end

  factory :meeting_abstract_type do
  end

  factory :abstract do
    abstract { 'A quick little discussion of the meeting.' }
    meeting
    association :meeting_abstract_type
  end
end

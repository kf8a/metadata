require File.dirname(__FILE__) + '/../test_helper'

class DatasetTest < ActiveSupport::TestCase

  Factory.define :role do |r|
    r.role_type_id 1
    r.seniority 2
  end
  
  Factory.define :person do |person|
    person.sur_name 'meier'
    person.given_name 'bob'
  end

  context "A dataset" do

    setup do
      @dataset = Dataset.new
      Factory(:role, :id => 7, :name => 'investigator')
      Factory(:role, :id => 8, :name => 'contact')
      Factory(:person, :given_name => 'bob')
      Factory(:person, :given_name => 'sue')
      Factory(:person, :given_name => 'bill')
      @params ={"role_ids"=>[{:id => "7", "person_ids"=>["1", "2", "3"]}, {:id => "8", "person_ids"=>["2"]}]}
    end

    should 'accept new dataset affiliations' do 
      assert @dataset.dataset_affiliations=@params 
    end
    
    should 'add 4 people to the dataset' do
       assert @dataset.people == []
       @dataset.dataset_affiliations=@params
       p @dataset.to_yaml
       assert @dataset.affiliations.size == 4
     end
    
    
    should 'add people with 2 roles' do
      assert @dataset.roles == []
      @dataset.dataset_affiliations=@params
      assert @dataset.roles.size == 2
    end
    
     
    
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dataset do
  before(:each) do
    @valid_attributes = {
      :title => 'KBS004',
      :abstract => 'the main lter experiment'
    }
  end

  it "should create a new instance given valid attributes" do
    Dataset.create!(@valid_attributes)
  end
  
  it "should belong to a project" do
    dataset = Dataset.create!(@valid_attributes)
    dataset.project = Project.new
    dataset.save
  end
end  

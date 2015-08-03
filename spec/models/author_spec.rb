require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

describe Author do
  it { should belong_to :citation }
  it { should validate_presence_of :seniority }

  context 'an author with a last name' do
    before(:each) do
      @author1 = FactoryGirl.create :author, :sur_name => 'Bond'
      @author2 = FactoryGirl.create :author, :sur_name => 'Bond', :given_name => ''
    end

    it 'is formatted as the last name' do
      @author1.formatted.should == 'Bond'
      @author2.formatted.should == 'Bond'
    end

    it 'is formatted as last name with the natural order' do
      @author1.formatted(:natural).should == 'Bond'
    end
  end

  context 'an author with a first and last name' do
    before(:each) do
      @author1 = FactoryGirl.create :author, :sur_name => 'Bond', :given_name => 'Bill'
      @author2 = FactoryGirl.create :author, :sur_name => 'Bond', :given_name => 'B.'
    end

    it 'is formatted correctly by default' do
      @author1.formatted.should == 'Bond, B.'
      @author2.formatted.should == 'Bond, B.'
    end

    it 'is formatted correctly as natural' do
      @author1.formatted(:natural).should == 'B. Bond'
      @author2.formatted(:natural).should == 'B. Bond'
    end
  end

  context 'an author with a middle name' do
    before do
      @author1 = FactoryGirl.create :author, :sur_name => 'Bond', :given_name => 'Bill', :middle_name => 'karl'
    end

    it 'is formatted as default' do
      @author1.formatted.should == 'Bond, B. K.'
    end

    it 'is formatted as natural' do
      @author1.formatted(:natural).should == 'B. K. Bond'
    end
  end

  context 'an author with a double last name' do
    before do
      @author = FactoryGirl.create :author, :sur_name => 'Al Fazier', :given_name => 'John'
    end

    it 'has the right name' do
      @author.name.should == 'Al Fazier, John'
    end

    it 'is formatted as default' do
      @author.formatted.should == 'Al Fazier, J.'
    end

    it 'is formatted as natural' do
      @author.formatted(:natural).should == 'J. Al Fazier'
    end
  
  end
end

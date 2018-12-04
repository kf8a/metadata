require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

describe Author do
  it { should belong_to :citation }
  it { should validate_presence_of :seniority }

  context 'an author with a last name' do
    before(:each) do
      @author1 = FactoryBot.create :author, sur_name: 'Bond'
      @author2 = FactoryBot.create :author, sur_name: 'Bond', given_name: ''
    end

    it 'is formatted as the last name' do
      expect(@author1.formatted).to eq 'Bond'
      expect(@author2.formatted).to eq 'Bond'
    end

    it 'is formatted as last name with the natural order' do
      expect(@author1.formatted(:natural)).to eq 'Bond'
    end
  end

  context 'an author with a first and last name' do
    before(:each) do
      @author1 = FactoryBot.create :author, sur_name: 'Bond', given_name: 'Bill'
      @author2 = FactoryBot.create :author, sur_name: 'Bond', given_name: 'B.'
    end

    it 'is formatted correctly by default' do
      expect(@author1.formatted).to eq 'Bond, B.'
      expect(@author2.formatted).to eq 'Bond, B.'
    end

    it 'is formatted correctly as natural' do
      expect(@author1.formatted(:natural)).to eq 'B. Bond'
      expect(@author2.formatted(:natural)).to eq 'B. Bond'
    end
  end

  context 'an author with a middle name' do
    before do
      @author1 = FactoryBot.create :author, sur_name: 'Bond', given_name: 'Bill',
                                            middle_name: 'karl'
    end

    it 'is formatted as default' do
      expect(@author1.formatted).to eq 'Bond, B. K.'
    end

    it 'is formatted as natural' do
      expect(@author1.formatted(:natural)).to eq 'B. K. Bond'
    end
  end

  context 'an author with a double last name' do
    before do
      @author = FactoryBot.create :author, sur_name: 'Al Fazier', given_name: 'John'
    end

    it 'has the right name' do
      expect(@author.name).to eq 'Al Fazier, John'
    end

    it 'is formatted as default' do
      expect(@author.formatted).to eq 'Al Fazier, J.'
    end

    it 'is formatted as natural' do
      expect(@author.formatted(:natural)).to eq 'J. Al Fazier'
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

describe Treatment do
  it { should belong_to :study }
  it { should have_and_belong_to_many :citations }
end

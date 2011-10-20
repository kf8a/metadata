require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe VenueType do
  it { should validate_presence_of :name}
end

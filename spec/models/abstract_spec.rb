require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Abstract do
  it {should validate_presence_of :meeting}
  it {should validate_presence_of :abstract}
end

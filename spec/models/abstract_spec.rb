require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

describe Abstract do
  it {should validate_presence_of :meeting}
end

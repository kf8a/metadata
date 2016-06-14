require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

describe Permission do
  before(:each) do
    @permission = Permission.new
  end

  it { should validate_presence_of :user }
  it { should validate_presence_of :datatable }
  it { should validate_presence_of :owner }
end

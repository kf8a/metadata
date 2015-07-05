require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Permission do
  before(:each) do
    @permission = Permission.new
  end

  it { should validate_presence_of :user }
  it { should validate_presence_of :datatable }
  it { should validate_presence_of :owner }
end






# == Schema Information
#
# Table name: permissions
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  datatable_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#  owner_id     :integer
#  decision     :string(255)
#


require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

describe Scribble do
  before(:each) do
    @valid_attributes = {
    }
  end

  it 'should create a new instance given valid attributes' do
    Scribble.create!(@valid_attributes)
  end
end

# == Schema Information
#
# Table name: scribbles
#
#  id          :integer         not null, primary key
#  person_id   :integer
#  protocol_id :integer
#  weight      :integer
#

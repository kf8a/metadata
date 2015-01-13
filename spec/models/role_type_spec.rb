require 'spec_helper'

describe RoleType do
  it { should have_many :roles }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name) }
end

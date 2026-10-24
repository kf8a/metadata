# frozen_string_literal: true

require 'rails_helper'

describe Permission do
  before(:each) do
    @permission = Permission.new
  end

  it { should validate_presence_of :user }
  it { should validate_presence_of :datatable }
  it { should validate_presence_of :owner }

  describe 'only owners can set permissions' do
    before do
      @datatable = FactoryBot.create(:datatable)
      @owner = FactoryBot.create(:user)
      Ownership.create!(user: @owner, datatable: @datatable)
      @user = FactoryBot.create(:user)
    end

    it 'is valid when the owner grants it' do
      permission = Permission.new(datatable: @datatable, owner: @owner, user: @user)
      expect(permission).to be_valid
    end

    it 'is invalid when a non-owner grants it' do
      non_owner = FactoryBot.create(:user)
      permission = Permission.new(datatable: @datatable, owner: non_owner, user: @user)

      expect(permission).not_to be_valid
      expect(permission.errors[:base]).to include('owners only')
    end
  end
end

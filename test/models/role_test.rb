require File.expand_path('../../test_helper', __FILE__)

class RoleTest < ActiveSupport::TestCase
  context 'evaluating a role' do
    setup do
      @emeritus = FactoryBot.create(:role)

      @non_emeritus = FactoryBot.create(:role)
      @non_emeritus.name = 'Something elese'
    end

    should 'return true for emeritus role' do
      assert @emeritus.emeritus?
    end

    should 'return false for non-emeritus role' do
      assert !@non_emeritus.emeritus?
    end
  end

  context 'committee? function' do
    setup do
      @committee_member = FactoryBot.create(:role, name: 'Committee')
      @network_rep = FactoryBot.create(:role, name: 'Network Representatives')
      @non_committee = FactoryBot.create(:role, name: 'Not on a committee')
    end

    should 'return true for Committee role' do
      assert @committee_member.committee?
    end

    should 'return true for Network Representatives role' do
      assert @network_rep.committee?
    end

    should 'return false for non-committee role' do
      assert !@non_committee.committee?
    end
  end

  context 'data_roles function' do
    setup do
      @lter_roletype = RoleType.find_by_name('lter_dataset')
      @lter_roletype ||= FactoryBot.create(:role_type, name: 'lter_dataset')
      @role1 = FactoryBot.create(:role, role_type: @lter_roletype)
      @role2 = FactoryBot.create(:role, role_type: @lter_roletype)
      @role3 = FactoryBot.create(:role, role_type: @lter_roletype)
    end

    should 'find all of the lter_dataset roles' do
      assert Role.data_roles.include?(@role1)
      assert Role.data_roles.include?(@role2)
      assert Role.data_roles.include?(@role3)
    end
  end
end

# == Schema Information
#
# Table name: roles
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  role_type_id       :integer
#  seniority          :integer
#  show_in_overview   :boolean         default(TRUE)
#  show_in_detailview :boolean         default(TRUE)
#

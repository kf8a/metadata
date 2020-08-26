require File.expand_path('../../test_helper', __FILE__)

class PermissionTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to :datatable
  should belong_to :owner

  should validate_presence_of :user
  should validate_presence_of :datatable
  should validate_presence_of :owner

  context 'basic permissions' do
    setup do
      user        = FactoryBot.create :user
      owner       = FactoryBot.create :user
      datatable   = FactoryBot.create :datatable
      datatable.owners = [owner]

      @permission = FactoryBot.build :permission,
                                      datatable: datatable,
                                      user: user,
                                      owner: owner
    end

    should 'be valid' do
      assert @permission.valid?
    end
  end

  context 'setting permissions' do
    setup do
      @owner      = FactoryBot.create :user
      @datatable  = FactoryBot.create :datatable
      @datatable.owners = [@owner]
    end

    should 'allow the owner to give users permission' do
      p           = Permission.new(datatable: @datatable)
      p.owner     = @owner
      p.user      = FactoryBot.create :user

      assert p.valid?
    end

    should 'not allow a non owner to give users permission' do
      p           = Permission.new
      p.datatable = @datatable
      p.owner     = FactoryBot.create(:user)
      p.user      = FactoryBot.create(:user)

      assert !p.valid?
      assert_equal ['owners only'], p.errors[:base]
    end

    should 'not allow permissions to be set more than once' do
      user         = FactoryBot.create(:user)

      p1           = Permission.new
      p1.datatable = @datatable
      p1.owner     = @owner
      p1.user      = user

      p2           = Permission.new
      p2.datatable = @datatable
      p2.owner     = @owner
      p2.user      = user

      assert p1.valid?
      assert p1.save
      refute p2.valid?
      assert p1.valid?
    end

    should 'allow permissions to be updated' do
      user         = FactoryBot.create :user

      p1           = Permission.new
      p1.datatable = @datatable
      p1.owner     = @owner
      p1.user      = user
      p1.save

      permission = Permission.find_by_datatable_id_and_owner_id_and_user_id(@datatable,
                                                                            @owner, user)
      permission.decision = 'approved'
      assert permission.valid?
      assert permission.save
    end

    should 'allow permissions from multiple owners' do
      user = FactoryBot.create :user
      owner2 = FactoryBot.create :user
      FactoryBot.create :ownership, user: owner2, datatable: @datatable
      @datatable.reload
      assert_equal [@owner, owner2], @datatable.owners

      p1           = Permission.new
      p1.datatable = @datatable
      p1.owner     = @owner
      p1.user      = user
      p1.save

      p2 = Permission.new
      p2.datatable = @datatable
      p2.owner     = owner2
      p2.user      = user

      assert p2.valid?
      assert p2.save
    end
  end

  context 'Person.permitted_users' do
    should 'list all undenied users' do
      user1 = FactoryBot.create(:user)
      user2 = FactoryBot.create(:user)
      user3 = FactoryBot.create(:user)
      user4 = FactoryBot.create(:user)
      owner1 = FactoryBot.build :user
      owner2 = FactoryBot.build :user
      datatable1 = FactoryBot.create :datatable
      datatable1.owners = [owner1]
      datatable2 = FactoryBot.create :datatable
      datatable2.owners = [owner2]
      FactoryBot.create(:permission, owner: owner1, datatable: datatable1,
                                      user: user1, decision: 'approved')
      FactoryBot.create(:permission, owner: owner1, datatable: datatable1,
                                      user: user2, decision: 'denied')
      FactoryBot.create(:permission, owner: owner2, datatable: datatable2,
                                      user: user4, decision: 'approved')

      assert Permission.permitted_users.include?(user1)
      assert !Permission.permitted_users.include?(user2)
      assert !Permission.permitted_users.include?(user3)
      assert Permission.permitted_users.include?(user4)
    end
  end
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

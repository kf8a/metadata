require File.expand_path('../../test_helper',__FILE__)

class PermissionTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to :datatable
  should belong_to :owner

  should validate_presence_of :user
  should validate_presence_of :datatable
  should validate_presence_of :owner

  context 'basic permissions' do
    setup do
      user        = FactoryGirl.create :user
      owner       = FactoryGirl.create :user
      datatable   = FactoryGirl.create :datatable
      datatable.owners = [owner]

      @permission = FactoryGirl.build :permission,
        :datatable  => datatable,
        :user       => user,
        :owner      => owner
    end

    should 'be valid' do
      assert @permission.valid?
    end

  end

  context 'setting permissions' do
    setup do
      @owner      = FactoryGirl.create :user
      @datatable  = FactoryGirl.create :datatable
      @datatable.owners = [@owner]
    end

    should 'allow the owner to give users permission' do
      p           = Permission.new({:datatable => @datatable})
      p.owner     = @owner
      p.user      = FactoryGirl.create :user

      assert p.valid?
    end

    should 'not allow a non owner to give users permission' do
      p           = Permission.new
      p.datatable = @datatable
      p.owner     = FactoryGirl.create(:user)
      p.user      = FactoryGirl.create(:user)

      assert !p.valid?
      assert_equal ['owners only'], p.errors[:base]
    end

    should 'not allow permissions to be set more than once' do
      user         = FactoryGirl.create(:user)

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
      user         = FactoryGirl.create :user

      p1           = Permission.new
      p1.datatable = @datatable
      p1.owner     = @owner
      p1.user      = user
      p1.save

      permission = Permission.find_by_datatable_id_and_owner_id_and_user_id(@datatable, @owner, user)
      permission.decision = "approved"
      assert permission.valid?
      assert permission.save
    end

    should 'allow permissions from multiple owners' do
      user         = FactoryGirl.create :user

      owner2       = FactoryGirl.create :user
      FactoryGirl.create :ownership, :user => owner2, :datatable => @datatable
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
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      user3 = FactoryGirl.create(:user)
      user4 = FactoryGirl.create(:user)
      owner1 = FactoryGirl.build :user
      owner2 = FactoryGirl.build :user
      datatable1  = FactoryGirl.create :datatable
      datatable1.owners = [owner1]
      datatable2  = FactoryGirl.create :datatable
      datatable2.owners = [owner2]
      FactoryGirl.create(:permission, :owner => owner1, :datatable => datatable1, :user => user1, decision: "approved")
      FactoryGirl.create(:permission, :owner => owner1, :datatable => datatable1, :user => user2, :decision => 'denied')
      FactoryGirl.create(:permission, :owner => owner2, :datatable => datatable2, :user => user4, decision: "approved")

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


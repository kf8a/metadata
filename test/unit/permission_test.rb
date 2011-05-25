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
      user        = Factory :user
      owner       = Factory :user
      datatable   = Factory :datatable, :owners => [owner]

      @permission = Factory.build :permission,
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
      @owner      = Factory :user
      @datatable  = Factory :datatable, :owners => [@owner]
    end

    should 'allow the owner to give users permission' do
      p           = Permission.new({:datatable => @datatable})
      p.owner     = @owner
      p.user      = Factory :user

      assert p.valid?
    end

    should 'not allow a non owner to give users permission' do
      p           = Permission.new
      p.datatable = @datatable
      p.owner     = Factory :user
      p.user      = Factory :user

      assert !p.valid?
      assert_equal ['owners only'], p.errors[:base]
    end

    should 'not allow permissions to be set more than once' do
      user         = Factory :user

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
      user         = Factory :user

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
      user         = Factory :user

      owner2       = Factory :user
      Factory.create(:ownership, :user => owner2, :datatable => @datatable)
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
      user1 = Factory :user
      user2 = Factory :user
      user3 = Factory :user
      user4 = Factory :user
      owner1 = Factory :user
      owner2 = Factory :user
      datatable1  = Factory :datatable, :owners => [owner1]
      datatable2  = Factory :datatable, :owners => [owner2]
      Factory :permission, :owner => owner1, :datatable => datatable1, :user => user1
      Factory :permission, :owner => owner1, :datatable => datatable1, :user => user2, :decision => 'denied'
      Factory :permission, :owner => owner2, :datatable => datatable2, :user => user4

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


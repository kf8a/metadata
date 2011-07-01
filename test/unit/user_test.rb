require File.expand_path('../../test_helper',__FILE__) 

class UserTest < ActiveSupport::TestCase

  setup do
    @user = Factory.create(:user)
  end
  
  should have_many :permissions
  should have_many :datatables
  
  should have_many :memberships
  should have_many :sponsors
  
  should validate_uniqueness_of(:email).case_insensitive.with_message(/this email account is already registered/)
  
  context 'a user' do
    setup do
      @user = Factory :user
    end
    
    should 'include admin role' do
      assert User::ROLES.include?('admin')
    end
    
    should 'respond to has_permission_from?' do
      assert @user.respond_to?('has_permission_from?')
    end
    
    should 'not be an admin' do
      assert !@user.admin?
    end
  end
  
  context 'an admin user' do
    setup do
      @user = Factory :admin_user
    end
    
    should 'be an admin?' do
      assert @user.admin?
    end
  end
  
  context 'membership in sponsors' do
    setup do 
      
      @user = Factory.create :user
    end
    
    should 'accept membership in a sponsor' do
      sponsor = Factory.create :sponsor, :data_use_statement => 'Use it', :name => 'GLBRC'
      assert @user.sponsors << [sponsor]
    end
    
  end

  context "the owns(datatable) function" do
    context "with a protected datatable" do
      setup do
        @datatable = Factory.create(:protected_datatable)
      end
      
      context "and an owner" do
        setup do
          @owner = Factory.create(:email_confirmed_user)
          Factory.create(:ownership, :user => @owner, :datatable => @datatable)
        end
        
        should "own the datatable" do
          assert @owner.owns?(@datatable)
        end
      end
      
      context "and a non-owner" do
        setup do
          @nonowner = Factory.create(:email_confirmed_user)
        end
        
        should "not own the datatable" do
          assert ! @nonowner.owns?(@datatable)
        end
      end
    end
  end

  context 'An owner has given a user permission to use a datatable.' do
    setup do
      @datatable = Factory.create(:protected_datatable)
      @owner = Factory.create(:email_confirmed_user)
      Factory.create(:ownership, :user => @owner, :datatable => @datatable)
      Factory.create(:permission, :user => @user, :owner => @owner, :datatable => @datatable)
    end

    context '#has_permission_from?' do
      setup do
        @has_permission_from = @user.has_permission_from?(@owner, @datatable)
      end

      should 'be true' do
        assert @has_permission_from
      end
    end

    context 'another user has been denied acces to use the datatable.' do
      setup do
        @another_user = Factory.create(:email_confirmed_user)
        Factory.create(:permission, :user => @another_user, :owner => @owner, :datatable => @datatable, :decision => 'denied')
      end

      context '#has_permission_from?' do
        setup do
          @has_permission_from = @another_user.has_permission_from?(@owner, @datatable)
        end

        should 'be false' do
          assert !@has_permission_from
        end
      end
    end
  end
  
end





# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  email              :string(255)
#  encrypted_password :string(128)
#  salt               :string(128)
#  confirmation_token :string(128)
#  remember_token     :string(128)
#  email_confirmed    :boolean         default(FALSE), not null
#  created_at         :datetime
#  updated_at         :datetime
#  identity_url       :string(255)
#  role               :string(255)
#


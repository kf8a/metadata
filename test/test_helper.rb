ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "../../config/environment")
require 'rails/test_help'
require 'shoulda'
require 'factory_girl'
require 'clearance/testing'
FactoryGirl.reload
require Rails.root.join('test', 'shoulda_macros', 'paperclip')

require "#{Rails.root}/db/seeds.rb"

class ActiveSupport::TestCase
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...

  def signed_in_as_admin
    admin = User.find_by_role('admin') || FactoryGirl.create(:admin_user, :email => 'admin@example.com')
    sign_in_as(admin)
  end

  def signed_in_as_normal_user
    user = User.find_by_role('') || FactoryGirl.create(:user, :email => 'normal_user@example.com')
    sign_in_as(user)
  end

  def self.should_have_attached_file(attachment)
    klass = self.name.gsub(/Test$/, '').constantize

    context "To support a paperclip attachment named #{attachment}, #{klass}" do
      should_have_db_column("#{attachment}_file_name",    :type => :string)
      should_have_db_column("#{attachment}_content_type", :type => :string)
      should_have_db_column("#{attachment}_file_size",    :type => :integer)
    end

    should "have a paperclip attachment named ##{attachment}" do
      assert klass.new.respond_to?(attachment.to_sym),
      "@#{klass.name.underscore} doesn't have a paperclip field named #{attachment}"
      assert_equal Paperclip::Attachment, klass.new.send(attachment.to_sym).class
    end
  end

  def self.should_accept_nested_attributes_for(*associations)
    klass = self.name.gsub(/Test$/, '').constantize

    associations.each do |association|
      should "accept nested attributes for #{association}" do
        assert klass.new.respond_to?("#{association}_attributes="), "#{klass} does not accept nested attributes for association: #{association}"
      end
    end
  end

  # from http://github.com/maxim/shmacros
  # def self.should_validate_associated(*associations)
  #   klass = self.name.gsub(/Test$/, '').constantize
  #   associations.each do |association|
  #     should "validate associated #{association}" do
  #       p klass.new.methods.grep(/valid/)
  #       assert klass.new.respond_to?("validate_associated_records_for_#{association}")
  #     end
  #   end
  # end
end

unless defined?(Test::Unit::AssertionFailedError)
  class Test::Unit::AssertionFailedError < ActiveSupport::TestCase::Assertion
  end
end

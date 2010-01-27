ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
# gem 'flexmock'
# require 'flexmock/test_unit'

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
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
  #load File.join(RAILS_ROOT,'test', 'mocks', 'test', 'authenticated_mock.rb')
  
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
    
    
    Factory.define :datatable do |d|
       d.name 'KBS001_001'
       d.object 'select now() as sample_date'
       d.is_sql true
       d.description 'This is a datatable'
     end

    Factory.define :person do |p|
      p.sur_name 'bauer'
      p.given_name 'bill'
    end

    Factory.define :theme do |t|
      t.title  'Agronomic'
    end

    Factory.define :dataset do |d|
      d.title 'KBS001'
      d.abstract 'some new dataset'
    end

    Factory.define :protocol do |p|
      p.name  'Proto1'
      p.version  0
      p.dataset Factory.create(:dataset)
    end
    
    Factory.define :study do |s|
      s.name 'LTER'
    end

end


require File.dirname(__FILE__) + '/../test_helper'

class CitationTest < ActiveSupport::TestCase
  should belong_to :citation_type
  should have_many :authors
  should belong_to :website

  context 'a citation object' do
    setup do
      @citation = Factory :citation
    end
    
    should 'be valid' do
      assert @citation.valid?
    end
    
    should 'respond to citation' do
      assert @citation.respond_to?('citation')
    end
    
    should 'return a string for citation' do
      assert_kind_of String, @citation.citation
    end
    
  end
end

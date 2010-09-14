require File.dirname(__FILE__) + '/../test_helper'

class CitationTest < ActiveSupport::TestCase
  should belong_to :citation_type
  should have_many :authors
  should belong_to :website
  
  should have_attached_file(:pdf)

  context 'a citation object' do
    setup do
      @citation = Factory :citation
    end
    
    should 'be valid' do
      assert @citation.valid?
    end
    
  end
end

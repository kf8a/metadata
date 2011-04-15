require File.expand_path('../../test_helper',__FILE__) 

class CitationTypeTest < ActiveSupport::TestCase  
  should have_many :citations
end

# == Schema Information
#
# Table name: citation_types
#
#  id           :integer         not null, primary key
#  abbreviation :string(255)
#  name         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#


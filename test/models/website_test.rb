require File.expand_path('../../test_helper', __FILE__)

class WebsiteTest < ActiveSupport::TestCase
  should have_many :datasets
  should have_and_belong_to_many :protocols
  should have_many :study_urls

  should have_many :citations
  should have_many :article_citations
  should have_many :book_citations
  should have_many :thesis_citations

  should validate_presence_of :name
end

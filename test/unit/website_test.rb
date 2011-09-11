require File.expand_path('../../test_helper',__FILE__) 

class WebsiteTest < ActiveSupport::TestCase
  should have_many :datasets
  should have_many :templates
  should have_and_belong_to_many :protocols
  should have_many :study_urls

  should have_many :citations
  should have_many :article_citations
  should have_many :book_citations
  should have_many :thesis_citations
  
  should validate_presence_of :name
    
  context 'website' do
    setup do
      @template = Factory.create(:template,  :controller => 'datatable', 
                                                :action => 'show', 
                                                :layout => 'Hi')
      @website = Factory.create(:website, :templates => [@template])
  
      @website.save
      @template.save

      Factory.create(:template, :controller => 'datatable', 
                                :action => 'show',
                                :website_id => 2,
                                :layout => 'nothing').save
    end

    # This needs to have a record in the database before it will pass
    should validate_uniqueness_of :name
    
    should 'find a template' do
      assert !@website.layout('datatable', 'show').nil?
    end

    should 'find the right template' do
      assert @website.layout('datatable', 'show').kind_of?(Liquid::Template)
      assert Liquid::Template.parse(@template.layout).render == @website.layout('datatable', 'show').render
    end

  end
end






# == Schema Information
#
# Table name: websites
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  data_catalog_intro :text
#


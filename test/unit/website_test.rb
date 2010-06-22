require 'test_helper'

class WebsiteTest < ActiveSupport::TestCase
  should_have_many :datatables
  should_have_many :templates

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

    should 'find a template' do
      assert !@website.layout('datatable', 'show').nil?
    end

    should 'find the right template' do
      assert @website.layout('datatable', 'show').kind_of?(Liquid::Template)
      assert Liquid::Template.parse(@template.layout).render == @website.layout('datatable', 'show').render
    end

  end
end

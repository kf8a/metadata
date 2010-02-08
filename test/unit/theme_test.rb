require File.dirname(__FILE__) + '/../test_helper'

class ThemeTest < ActiveSupport::TestCase
  should_have_and_belong_to_many :datasets
  should_have_many :datatables
  
  context 'themes querying for datatables' do
    
    setup do 
      @study = Factory.create(:study)
      @datatable = Factory.create(:datatable)
      
      @dataset = Factory.create(:dataset)
      @dataset.studies << [@study]
      @dataset.datatables << [@datatable]
      
      @theme = Factory.create(:theme)
      @sub_theme = Factory.create(:theme)
      @sub_sub_theme = Factory.create(:theme)
      
      @sub_theme.move_to_child_of(@theme)
      @sub_sub_theme.move_to_child_of(@sub_theme)
    end
    
    should 'respond to has_datatables?' do
      assert @theme.respond_to?('has_datatables?')
    end
    
    should 'return true if @theme has a datatable' do
      @datatable.theme = @theme
      assert @datatable.save
      assert @theme.has_datatables?
    end
    
    should 'return false if @theme does not have a datatable' do
      assert !@theme.has_datatables?
    end
    
    should 'return true if the subtheme has a datatable' do
      @datatable.theme = @sub_theme
      assert @datatable.save
      assert @theme.has_datatables?
    end
    
    should 'return true if the sub sub theme has a datatable' do
      @datatable.theme = @sub_sub_theme
      assert @datatable.save
      assert @theme.has_datatables?
    end
         
    should 'return true if a datatable is in the current study' do  
      @datatable.theme = @theme
      assert @datatable.save
      assert @theme.has_datatables?(@study)
    end
      
    should 'return false if a datatable is in a different study' do
      @datatable.theme = @theme
      assert @datatable.save
      study = Factory.create(:study)
      assert !@theme.has_datatables?(study)
    end

  end
  
end

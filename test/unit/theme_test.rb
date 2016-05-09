require File.expand_path('../../test_helper', __FILE__)

class ThemeTest < ActiveSupport::TestCase
  should have_and_belong_to_many :datasets
  should have_many :datatables

  context 'themes querying for datatables' do
    setup do
      @study = FactoryGirl.create(:study)
      @datatable = FactoryGirl.create(:datatable, study: @study)

      @theme = FactoryGirl.create(:theme)
      @sub_theme = FactoryGirl.create(:theme)
      @sub_sub_theme = FactoryGirl.create(:theme)

      @sub_theme.move_to_child_of(@theme)
      @sub_sub_theme.move_to_child_of(@sub_theme)
    end

    should 'respond to datatables?' do
      assert @theme.respond_to?('datatables?')
    end

    should 'return true if @theme has a datatable' do
      @datatable.theme = @theme
      assert @datatable.save
      assert @theme.datatables?
    end

    should 'return false if @theme does not have a datatable' do
      assert !@theme.datatables?
    end

    should 'return true if the subtheme has a datatable' do
      @datatable.theme = @sub_theme
      assert @datatable.save
      assert @theme.datatables?
    end

    should 'return true if the sub sub theme has a datatable' do
      @datatable.theme = @sub_sub_theme
      assert @datatable.save
      assert @theme.datatables?
    end

    should 'return true if a datatable is in the current study' do
      @datatable.theme = @theme
      assert @datatable.save
      assert @theme.datatables?(@study)
    end

    should 'return false if a datatable is in a different study' do
      @datatable.theme = @theme
      assert @datatable.save
      study = FactoryGirl.create(:study)
      assert !@theme.datatables?(study)
    end

    context 'include_datatables?' do
      should 'return false if the datatable is not in the current theme' do
        datatable = FactoryGirl.create(:datatable)
        assert !@theme.include_datatables?([datatable])
      end

      should 'return true if the datatable is in the current theme' do
        @datatable.theme = @theme
        assert @datatable.save
        assert @theme.datatables?
        assert @theme.include_datatables?([@datatable])
      end

      context 'include_datatables_from_study' do
        setup do
          @datatable.theme = @theme
          FactoryGirl.create(:study)
          assert @datatable.save
        end

        should 'return true if if the datatable is in the same study' do
          assert @theme.include_datatables_from_study?([@datatable], @study)
        end

        should 'return false if the datatable is in a different study ' do
          assert !@theme.include_datatables_from_study?([@datatable], @study2)
        end

        should 'return false if there is an empty array passed' do
          assert !@theme.include_datatables_from_study?([], @study2)
          assert !@theme.include_datatables_from_study?([], @study)
        end

        should 'only return datatables from the offered tables' do
          assert @theme.datatables_in_study(@study) == [@datatable]
        end
      end
    end

    context 'datatables_in_study function' do
      context 'and a study with datatables' do
        setup do
          @datatable.theme = @theme
          assert @datatable.save
          @datatable2 = FactoryGirl.create(:datatable, study: @study, theme: @theme)
          @outside_datatable = FactoryGirl.create(:datatable, theme: @theme)
        end

        should 'show all of the datatables in the study' do
          assert @theme.datatables_in_study(@study).include?(@datatable)
          assert @theme.datatables_in_study(@study).include?(@datatable2)
        end

        should 'not show datatable outside of the study' do
          assert !@theme.datatables_in_study(@study).include?(@outside_datatable)
        end

        should 'show only the datatables selected as test_datatables' do
          assert @theme.datatables_in_study(@study, [@datatable]).include?(@datatable)
          assert !@theme.datatables_in_study(@study, [@datatable]).include?(@datatable2)
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: themes
#
#  id        :integer         not null, primary key
#  name      :string(255)
#  weight    :integer
#  parent_id :integer
#  lft       :integer
#  rgt       :integer
#

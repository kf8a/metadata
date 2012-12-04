require File.expand_path('../../test_helper',__FILE__)

class StudyTest < ActiveSupport::TestCase

  should have_many :datatables
  should have_and_belong_to_many :datasets
  should have_many :study_urls

  context 'querying for datatables' do
    setup do
      theme = FactoryGirl.create(:theme)
      @study = FactoryGirl.create(:study, :weight => 200)
      2.times {FactoryGirl.create(:study) }
      @study2 = FactoryGirl.create(:study, :weight=>100)

      @datatable  = FactoryGirl.create(:datatable, :study => @study)
      @datatable2 = FactoryGirl.create(:datatable, :study => @study2)
      @datatable3 = FactoryGirl.create(:datatable, :study => @study)
    end

    should 'return true if queried for included datatables' do
      assert @study.include_datatables?([@datatable])
    end

    should 'return false if queried for a non affiliated datatable' do
      assert  !@study.include_datatables?([FactoryGirl.create(:datatable)])
    end

    should 'find only the studies that include the datatable' do
      assert_equal  [@study], Study.find_all_with_datatables([@datatable])
      assert_equal @study, Study.find_all_with_datatables([@datatable, @datatable3])[0]

      assert_equal  [@study], Study.find_all_roots_with_datatables([@datatable])
      assert_equal  [@study2], Study.find_all_with_datatables([@datatable2])
      assert_not_equal [@study2], Study.find_all_with_datatables([@datatable])
      assert_not_equal [@study], Study.find_all_with_datatables([@datatable2])
    end


    should 'return the studies in the proper order' do
      studies = Study.find_all_with_datatables([@datatable, @datatable2], {:order => :weight})
      assert_equal 2, studies.size
      assert_equal @study2,  studies[0]
      assert_equal @study,  studies[1]
    end
  end

  context 'querying for datatables with nested studies' do
    setup do
      @study = FactoryGirl.create(:study)
      #create a second root study
      FactoryGirl.create(:study)
      @child_study = FactoryGirl.create(:study)
      @child_study.move_to_child_of(@study)

      @datatable = FactoryGirl.create(:datatable, :study => @child_study)
    end

    should 'should return true for the parent study if the dataset is in the child study' do
      assert @study.include_datatables?([@datatable])
    end

    should 'return only the root studies' do
      assert Study.find_all_roots_with_datatables([@datatable]) == [@study]
    end
  end

  context 'querying for studies with thinking sphinks' do
    should 'should behave just as when calling with arrays'
  end

  context 'return the right url for the website' do
    setup do
      @study      = FactoryGirl.create(:study)
      @website_1  = FactoryGirl.create(:website, :name => 'first')
      @website_2  = FactoryGirl.create(:website, :name => 'second')
      study_url_1 = FactoryGirl.create(:study_url, :url => 'somewhere', :website => @website_1)
      study_url_2 = FactoryGirl.create(:study_url, :url => 'somewhere else', :website => @website_2)
      @study.study_urls << [study_url_1, study_url_2]
    end

    should 'get the right url for the website' do
      assert @study.study_url(@website_1) == 'somewhere'
      assert @study.study_url(@website_2) == 'somewhere else'
    end
  end

  context 'deleting studies' do
    setup do
      @study      = FactoryGirl.create(:study)
      @study.treatments << FactoryGirl.create(:treatment)
    end

    should 'not delete when it has a treatment in the study' do
      assert_equal false, @study.destroy
    end

    should 'delete after removing the treatment' do
      @study.treatments.clear
      assert_equal @study, @study.destroy
    end
  end
end




# == Schema Information
#
# Table name: studies
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :text
#  weight      :integer
#  parent_id   :integer
#  lft         :integer
#  rgt         :integer
#  synopsis    :text
#  url         :string(255)
#  code        :string(255)
#


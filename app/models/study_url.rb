# a study url is the place where there is more information about a study
class StudyUrl < ActiveRecord::Base
  belongs_to :study
  belongs_to :website
end

# == Schema Information
#
# Table name: study_urls
#
#  id         :integer         not null, primary key
#  website_id :integer
#  study_id   :integer
#  url        :string(255)
#

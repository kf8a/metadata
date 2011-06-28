class Treatment < ActiveRecord::Base
  belongs_to :study
  has_and_belongs_to_many :publications, :order => 'citation'
  has_and_belongs_to_many :citations
end




# == Schema Information
#
# Table name: treatments
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :text
#  study_id    :integer
#  weight      :integer
#

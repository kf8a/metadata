class Sponsor < ActiveRecord::Base
  # extend FriendlyId

  has_many :datasets
  has_many :memberships

  # friendly_id :name
end




# == Schema Information
#
# Table name: sponsors
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  data_restricted    :boolean         default(FALSE)
#  data_use_statement :text
#


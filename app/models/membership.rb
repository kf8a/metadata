class Membership < ActiveRecord::Base
  belongs_to :sponsor
  belongs_to :user
end

# == Schema Information
#
# Table name: memberships
#
#  id         :integer         not null, primary key
#  sponsor_id :integer
#  user_id    :integer
#


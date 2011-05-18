class PermissionRequest < ActiveRecord::Base

  belongs_to :user
  belongs_to :datatable

  validates_presence_of :user, :datatable
  validates_uniqueness_of :user_id, :scope => :datatable_id
end

# == Schema Information
#
# Table name: permission_requests
#
#  id           :integer         not null, primary key
#  datatable_id :integer
#  user_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#

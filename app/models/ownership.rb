class Ownership < ActiveRecord::Base
  belongs_to :user
  belongs_to :datatable

  validates_presence_of :user
  validates_presence_of :datatable

  validates_uniqueness_of :user_id, :scope => :datatable_id

  def Ownership.create_ownerships(users, datatables)
    users.each do |user|
      datatables.each do |table|
        ownership = Ownership.new(:user_id => user, :datatable_id => table)
        ownership.save
      end
    end
  end
end



# == Schema Information
#
# Table name: ownerships
#
#  id           :integer         not null, primary key
#  datatable_id :integer
#  user_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#


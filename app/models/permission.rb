class Permission < ActiveRecord::Base
  belongs_to :user
  belongs_to :datatable
  belongs_to :owner, :class_name => "User"
  
  validates_presence_of :user, :datatable, :owner
  validates_associated :user, :datatable, :owner
  
  validates_uniqueness_of :user_id, :scope => [:datatable_id, :owner_id]
  validate :only_owners_can_set_permissions

  def Permission.permitted_users
    all.collect { |permission| permission.user unless permission.denied? }.compact
  end
     
  def only_owners_can_set_permissions
    errors[:base] << 'owners only' unless datatable.try(:owners).to_a.include?(owner)
  end

  def denied?
    decision == "denied"
  end
end

# == Schema Information
#
# Table name: permissions
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  datatable_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#  owner_id     :integer
#  decision     :string(255)
#


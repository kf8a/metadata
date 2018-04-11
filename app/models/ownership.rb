# Link datatable to data owners
class Ownership < ApplicationRecord
  belongs_to :user
  belongs_to :datatable

  validates :user, presence: true
  validates :datatable, presence: true

  validates :user_id, uniqueness: { scope: :datatable_id }

  def self.create_ownerships(users, datatables, overwrite = false)
    datatables.each { |datatable| destroy_all(datatable_id: datatable) } if overwrite
    users.product(datatables).each do |user, table|
      ownership = Ownership.new(user_id: user, datatable_id: table)
      ownership.save
    end
  end
end

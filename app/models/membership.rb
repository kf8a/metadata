# Represents membership of a person in an organization
class Membership < ApplicationRecord
  belongs_to :sponsor
  belongs_to :user
end

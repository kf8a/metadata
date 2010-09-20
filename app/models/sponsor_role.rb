class SponsorRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :sponsor
end

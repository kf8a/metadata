# A sponsor controls the availablity and polcies of a dataset
class Sponsor < ApplicationRecord
  # extend FriendlyId

  has_many :datasets
  has_many :memberships

  # friendly_id :name
  def terms_of_use_path
    if terms_of_use_url.blank?
      "/sponsors/#{id}"
    else
      terms_of_use_url
    end
  end
end

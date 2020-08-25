# frozen_string_literal: true

# A sponsor controls the availablity and polcies of a dataset
class Sponsor < ApplicationRecord
  has_many :datasets, dependent: :nullify
  has_many :memberships, dependent: :destroy

  # friendly_id :name
  def terms_of_use_path
    if terms_of_use_url.present?
      "/sponsors/#{id}"
    else
      terms_of_use_url
    end
  end
end

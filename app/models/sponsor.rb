# frozen_string_literal: true

# A sponsor controls the availablity and polcies of a dataset
class Sponsor < ApplicationRecord
  has_many :datasets, dependent: :nullify
  has_many :memberships, dependent: :destroy

  # friendly_id :name
  def terms_of_use_path
    terms_of_use_url.presence || "/sponsors/#{id}"
  end
end

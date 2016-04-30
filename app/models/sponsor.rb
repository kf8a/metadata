# A sponsor controls the availablity and polcies of a dataset
class Sponsor < ActiveRecord::Base
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

# == Schema Information
#
# Table name: sponsors
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  data_restricted    :boolean         default(FALSE)
#  data_use_statement :text
#

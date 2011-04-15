class PublicationType < ActiveRecord::Base
  has_many :publications
end

# == Schema Information
#
# Table name: publication_types
#
#  id   :integer         not null, primary key
#  name :string(255)
#


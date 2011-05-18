class CitationType < ActiveRecord::Base
  has_many :citations
end

# == Schema Information
#
# Table name: citation_types
#
#  id           :integer         not null, primary key
#  abbreviation :string(255)
#  name         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

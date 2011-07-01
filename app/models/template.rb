class Template < ActiveRecord::Base
  belongs_to :website

end




# == Schema Information
#
# Table name: templates
#
#  id         :integer         not null, primary key
#  website_id :integer
#  controller :string(255)
#  action     :string(255)
#  layout     :text
#  created_at :datetime
#  updated_at :datetime
#


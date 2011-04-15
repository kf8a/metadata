class Upload < ActiveRecord::Base
end

# == Schema Information
#
# Table name: uploads
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  owners     :string(255)
#  abstract   :text
#  file       :binary
#  created_at :datetime
#  updated_at :datetime
#


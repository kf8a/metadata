require 'rails_helper'

describe Visualization do
  it {should belong_to :datatable}
end


# == Schema Information
#
# Table name: visualizations
#
#  id           :integer         not null, primary key
#  datatable_id :integer
#  title        :string(255)
#  body         :text
#  query        :text
#  graph_type   :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  x_axis_label :string(255)
#  y_axis_label :string(255)
#


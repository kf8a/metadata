class Visualization < ActiveRecord::Base
  belongs_to :datatable

  def data
    ActiveRecord::Base.connection.execute(self.query)
  end
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


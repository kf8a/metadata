# Retrieve data for the qc visualizations
class Visualization < ApplicationRecord
  belongs_to :datatable

  def data
    ActiveRecord::Base.connection.execute(query)
  end
end

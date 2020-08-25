# frozen_string_literal: true

# Retrieve data for the qc visualizations
class Visualization < ApplicationRecord
  belongs_to :datatable, optional: true

  def data
    ActiveRecord::Base.connection.execute(query)
  end
end

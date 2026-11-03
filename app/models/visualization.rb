# frozen_string_literal: true

# Retrieve data for the qc visualizations
class Visualization < ApplicationRecord
  belongs_to :datatable, optional: true

  def data
    ActiveRecord::Base.connection.execute(query)
  end

  # The data is the datatable's rows, so it follows the datatable's download rules (restricted,
  # members-only). A visualization without a datatable is public, as before.
  def viewable_by?(user)
    datatable.nil? || datatable.can_be_downloaded_by?(user)
  end
end

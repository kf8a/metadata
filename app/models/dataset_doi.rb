# frozen_string_literal: true

# DOI's associated Dataset
class DatasetDoi < ApplicationRecord
  belongs_to :dataset
end

# frozen_string_literal: true

# DOI's associated Dataset
class DatasetDoi < ActiveRecord::Base
  belongs_to :dataset
end

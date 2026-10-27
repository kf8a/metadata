# frozen_string_literal: true

# link datsets to citations
class DataUsage < ApplicationRecord
  belongs_to :dataset
  belongs_to :citation
end

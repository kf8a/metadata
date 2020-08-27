# frozen_string_literal: true

# data versions TODO: I think this can be removed, it's function is now
# supported by dois
class DataVersion < ApplicationRecord
  belongs_to :dataset
end

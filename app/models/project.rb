# Represents a project
class Project < ApplicationRecord
  has_many :datasets
end

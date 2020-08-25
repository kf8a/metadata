# frozen_string_literal: true

# Represents a project
class Project < ApplicationRecord
  has_many :datasets, dependent: :destroy
  has_many :person_projects, dependent: :destroy
  has_many :people, through: :person_projects
end

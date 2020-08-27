# frozen_string_literal: true

# joining people with projects
class PersonProject < ApplicationRecord
  belongs_to :person
  belongs_to :project
  belongs_to :role
end

class Editor < ActiveRecord::Base
  belongs_to :citation

  validates_presence_of :seniority
end

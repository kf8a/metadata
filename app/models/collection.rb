# frozen_string_literal: true

# A collection as opposed to a datatable
# a collection is supposed to be browsable
class Collection < ApplicationRecord
  belongs_to :datatable

  validates :datatable, presence: true

  delegate :dataset, to: :datatable

  delegate :keywords, to: :datatable

  delegate :perform_query, to: :datatable

  delegate :protocols, to: :dataset

  delegate :title_and_years, to: :datatable

  delegate :variates, to: :datatable

  def values
    @values ||= perform_query
  end
end

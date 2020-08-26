# frozen_string_literal: true

# An abstract presented at a local or national meeeting
class MeetingAbstractType < ApplicationRecord
  has_many :meeting_abstracts, dependent: :destroy
end

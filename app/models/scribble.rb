# scribbles connect people and protocols
class Scribble < ApplicationRecord
  belongs_to :person
  belongs_to :protocol
end

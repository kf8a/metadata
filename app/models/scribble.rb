class Scribble < ActiveRecord::Base
  belongs_to :person
  belongs_to :protocol
end

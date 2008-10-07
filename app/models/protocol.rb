class Protocol < ActiveRecord::Base
  belongs_to :dataset
  has_many :scribbles
  has_many :people, :through => :scribbles
end

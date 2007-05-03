class Publication < ActiveRecord::Base
  belongs_to :publication_type
  belongs_to :source
end

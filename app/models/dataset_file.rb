class DatasetFile < ActiveRecord::Base
  belongs_to :dataset
  attr_accessible :name, :data

  has_attached_file :data, :url => "/datasets/:id/download",
    :path => ":rails_root/uploads/datasets/:attachment/:id.:extension"
end

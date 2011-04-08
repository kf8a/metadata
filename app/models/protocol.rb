#TODO add an updated_by attribute to track who changed the protocol
class Protocol < ActiveRecord::Base
  belongs_to :dataset
  has_and_belongs_to_many :websites
  has_and_belongs_to_many :datatables
  has_many :scribbles
  has_many :people, :through => :scribbles

  versioned :dependent => :tracking

  def to_s
    "#{self.title}"
  end

  def deprecate!(other)
    other.active = false
    other.save
    self.deprecates = other.id
    self.version_tag = other.version_tag.to_i + 1
    save
  end

  def replaced_by
    Protocol.where(:deprecates => self.id).first
  end

  def dataset_description
    self.dataset.try(:dataset)
  end
end

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

# == Schema Information
#
# Table name: protocols
#
#  id             :integer         not null, primary key
#  name           :string(255)
#  title          :string(255)
#  version_tag    :integer
#  in_use_from    :date
#  in_use_to      :date
#  description    :text
#  abstract       :text
#  body           :text
#  person_id      :integer
#  created_on     :date
#  updated_on     :date
#  change_summary :text
#  dataset_id     :integer
#  active         :boolean         default(TRUE)
#  deprecates     :integer
#

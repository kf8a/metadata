class Abstract < ActiveRecord::Base
  set_table_name 'meeting_abstracts'
  belongs_to :meeting
  
  validates_presence_of :meeting
  validates_presence_of :abstract

  scope :by_authors, :order=> :authors
end

# == Schema Information
#
# Table name: meeting_abstracts
#
#  id         :integer         not null, primary key
#  title      :text
#  authors    :text
#  abstract   :text
#  meeting_id :integer
#


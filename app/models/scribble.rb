# scribbles connect people and protocols
class Scribble < ActiveRecord::Base
  belongs_to :person
  belongs_to :protocol
end

# == Schema Information
#
# Table name: scribbles
#
#  id          :integer         not null, primary key
#  person_id   :integer
#  protocol_id :integer
#  weight      :integer
#

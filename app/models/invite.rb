require 'digest/sha1'

class Invite < ActiveRecord::Base
  validates_presence_of :email, message: "can't be blank"
  validates_uniqueness_of :email, message: "is already registered"

  def self.unsent_invitations
    self.where(redeemed_at: nil, invite_code: nil)
  end

  def invited?
    self.invite_code.present? && self.invited_at.present?
  end

  def invite!
    self.invite_code = Digest::SHA1.hexdigest("--#{Time.now.utc.to_s}--#{self.email}--")
    self.invited_at = Time.now.utc
    self.save!
  end

  def self.find_redeemable(invite_code)
    self.where(:redeemed_at => nil, :invite_code => invite_code).first
  end

  def redeemed!
    self.redeemed_at = Time.now.utc
    self.save!
  end
end

# == Schema Information
#
# Table name: invites
#
#  id           :integer         not null, primary key
#  firstname    :string(255)
#  lastname     :string(255)
#  email        :string(255)
#  invite_code  :string(40)
#  invited_at   :datetime
#  redeemed_at  :datetime
#  glbrc_member :boolean
#

require 'digest/sha1'

# Keeps track of invites sent out to allow people to register to become members of a group
# or by allowed to download a dataset
class Invite < ApplicationRecord
  validates :email, presence: { message: "can't be blank" }
  validates :email, uniqueness: { message: 'is already registered' }

  def self.unsent_invitations
    where(redeemed_at: nil, invite_code: nil)
  end

  def invited?
    invite_code.present? && invited_at.present?
  end

  def invite!
    self.invite_code = Digest::SHA1.hexdigest("--#{Time.now.utc}--#{email}--")
    self.invited_at = Time.now.utc
    save!
  end

  def self.find_redeemable(invite_code)
    find_by(redeemed_at: nil, invite_code: invite_code)
  end

  def redeemed!
    self.redeemed_at = Time.now.utc
    save!
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

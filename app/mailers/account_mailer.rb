# frozen_string_literal: true

# Tells someone an admin has added an account for them (Admin::UsersController), with the link to set a
# password. Replies go to that admin.
class AccountMailer < ActionMailer::Base
  default from: -> { Devise.mailer_sender }

  def invitation(user, invitation_token, site:, invited_by:)
    @user = user
    @invited_by = invited_by
    @glbrc = site == 'glbrc'
    @host = Site.host(site)
    @accept_link = accept_user_invitation_url(invitation_token:, host: @host, protocol: 'https')
    @link_valid_days = Devise.invite_for.in_days.to_i
    mail(to: @user.email, subject: "An account on #{@host}", reply_to: invited_by.email)
  end
end

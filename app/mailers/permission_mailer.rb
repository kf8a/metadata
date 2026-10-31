# frozen_string_literal: true

# Tells users about their permission to download a datatable: when it is granted or extended, and a week
# before it ends. Replies go to the admin who granted it.
class PermissionMailer < ActionMailer::Base
  default from: -> { Devise.mailer_sender }

  def granted(permission)
    prepare(permission)
    mail(to: @user.email, subject: "You can download #{@datatable.name}", **reply_to)
  end

  # For a new account: the link to set a password, with what they can download
  def welcome(permission, invitation_token)
    prepare(permission)
    @accept_link = accept_user_invitation_url(invitation_token:, host: @host, protocol: 'https')
    @link_valid_days = Devise.invite_for.in_days.to_i
    @glbrc = @datatable.dataset&.sponsor&.name == 'glbrc'
    mail(to: @user.email, subject: "An account to download #{@datatable.name}", **reply_to)
  end

  def expiring(permission)
    prepare(permission)
    mail(to: @user.email, subject: "Your access to #{@datatable.name} ends on #{@expires_on}", **reply_to)
  end

  private

  def prepare(permission)
    @user = permission.user
    @datatable = permission.datatable
    @expires_on = permission.expires_on&.to_fs(:long)
    @granted_by = permission.granted_by
    # The datatable's own site (LTER or GLBRC), not the mailer's single default host
    @host = @datatable.dataset&.url.presence || default_url_options[:host]
    @link = "https://#{@host}/datatables/#{@datatable.id}"
  end

  def reply_to
    @granted_by ? { reply_to: @granted_by.email } : {}
  end
end

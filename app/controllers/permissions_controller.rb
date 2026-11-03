# frozen_string_literal: true

# Admins grant, extend and revoke permission to download restricted and members-only datatables.
# The owners agree to a request by email; an admin then grants it here.
class PermissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :admin?
  before_action :require_datatable, except: :index

  def index
    datatables = Datatable.joins(dataset: :sponsor)
    @datatables = datatables.where(is_restricted: true)
                            .or(datatables.where(sponsors: { data_restricted: true }))
                            .by_name
  end

  def show
    @requesters = @datatable.pending_requesters
    @permissions = @datatable.permissions.includes(:user, :granted_by).order(:expires_on)
  end

  def new; end

  # Grants permission, or extends it when the user already has one. An email without an account brings
  # the form back to ask for the person's name and institution; with those the account is created, and the
  # person is emailed a link to set a password (sent again whenever access is granted before they do).
  def create
    @email = params[:email].to_s.strip.downcase
    user = User.find_by(email: @email) || new_reader
    return ask_for_reader_details(user) if user.new_record? && !user.valid?(:invite_reader)

    permission = grant_to(user)
    @datatable.permission_requests.where(user:).delete_all
    send_grant_email(permission, user)
    notice = "#{user.email} may download #{@datatable.name} #{until_text(permission)}."
    redirect_to permission_path(@datatable), status: :see_other, notice:
  rescue ActiveRecord::RecordInvalid => e
    refuse(e.record.errors.full_messages.to_sentence)
  end

  def destroy
    permission = @datatable.permissions.find_by!(user_id: params.expect(:user))
    permission.destroy
    redirect_to permission_path(@datatable), status: :see_other,
                                             notice: "Permission revoked from #{permission.user.email}."
  end

  # Removes a request without granting it
  def dismiss
    request = @datatable.permission_requests.find_by!(user_id: params.expect(:user))
    request.destroy
    redirect_to permission_path(@datatable), status: :see_other,
                                             notice: "Request from #{request.user.email} dismissed."
  end

  private

  def new_reader
    User.new(email: @email, first_name: params[:first_name].to_s.strip, last_name: params[:last_name].to_s.strip,
             institution: params[:institution].to_s.strip)
  end

  def ask_for_reader_details(user)
    @new_reader = user
    details_given = [user.first_name, user.last_name, user.institution].any?(&:present?)
    message = if details_given || user.errors.include?(:email)
                user.errors.full_messages.to_sentence
              else
                "No account has the email #{@email}. Give the person's name and institution to create one."
              end
    refuse(message)
  end

  # Creates the account (or a fresh link for one never set up) and the permission together
  def grant_to(user)
    Permission.transaction do
      invite(user) if user.new_record? || user.invitation_pending?
      permission = @datatable.permissions.find_or_initialize_by(user:)
      permission.granted_by = current_user
      permission.expires_on = Permission.expiry_for(params[:expires_in])
      permission.intended_use = params[:intended_use].presence || permission.intended_use
      permission.site = subdomain_from_request # the emails link back to the site the admin is on
      permission.save!
      permission
    end
  end

  # devise_invitable makes the token; PermissionMailer#welcome sends it with the rest of the news
  def invite(user)
    user.invite!(current_user) { |invited| invited.skip_invitation = true }
  end

  # The link to set a password is sent straight away rather than through the job queue, so the token is
  # not stored in the queue's table. The token is only on the user just invited, not on permission.user.
  def send_grant_email(permission, user)
    if user.raw_invitation_token
      PermissionMailer.welcome(permission, user.raw_invitation_token).deliver_now
      user.current_invitation.update!(invitation_sent_at: Time.current) # the link's validity starts now
    else
      PermissionMailer.granted(permission).deliver_later
    end
  end

  def refuse(message)
    flash.now[:alert] = message
    render :new, status: :unprocessable_content
  end

  def until_text(permission)
    permission.expires_on ? "until #{permission.expires_on.to_fs(:long)}" : 'with no expiry'
  end

  def require_datatable
    @datatable = Datatable.find(params.expect(:id)) if params[:id]
    @datatable = Datatable.find(params.expect(:datatable)) if !@datatable && params[:datatable]
    return if @datatable

    redirect_to permissions_path, alert: 'Choose a datatable to manage its permissions.'
  end
end

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

  # Grants permission, or extends it when the user already has one
  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)
    return refuse("No account has the email #{params[:email]}") unless user

    permission = @datatable.permissions.find_or_initialize_by(user:)
    permission.granted_by = current_user
    permission.expires_on = Permission.expiry_for(params[:expires_in])
    return refuse(permission.errors.full_messages.to_sentence) unless permission.save

    @datatable.permission_requests.where(user:).delete_all
    PermissionMailer.granted(permission).deliver_later
    notice = "#{user.email} may download #{@datatable.name} #{until_text(permission)}."
    redirect_to permission_path(@datatable), status: :see_other, notice:
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

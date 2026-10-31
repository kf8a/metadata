# frozen_string_literal: true

module Admin
  # Admins add, edit and remove accounts, and give or take away memberships (which sponsors' members-only
  # data a user can download). A new account gets an email with a link to set a password, as from the
  # permission grant form.
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :admin?
    before_action :find_user, except: %i[index new create]

    def index
      @query = params[:q].to_s.strip
      @users = User.includes(:sponsors).order(:email)
      @users = @users.where(search_sql, q: "%#{User.sanitize_sql_like(@query)}%") if @query.present?
    end

    def new
      @user = User.new
    end

    def edit; end

    def create
      @user = User.new(user_params)
      return render :new, status: :unprocessable_content unless @user.valid?(:invite_reader)

      User.transaction { @user.invite!(current_user) { |invited| invited.skip_invitation = true } }
      send_invitation
      redirect_to admin_users_path, status: :see_other,
                                    notice: "Added #{@user.email} and sent a link to set a password."
    end

    def update
      @user.assign_attributes(user_params)
      if @user == current_user && !@user.admin?
        @user.errors.add(:role, "can't be taken from your own account")
        return render :edit, status: :unprocessable_content
      end
      return render :edit, status: :unprocessable_content unless @user.save

      redirect_to admin_users_path, status: :see_other, notice: "Saved #{@user.email}."
    end

    def destroy
      if @user == current_user
        redirect_to admin_users_path, status: :see_other, alert: "You can't remove your own account."
      else
        @user.destroy!
        redirect_to admin_users_path, status: :see_other, notice: "Removed #{@user.email}."
      end
    end

    # A fresh link for someone who hasn't set a password yet; earlier links keep working until one is used
    def resend_invitation
      return redirect_to edit_admin_user_path(@user), status: :see_other unless @user.invitation_pending?

      @user.invite!(current_user) { |invited| invited.skip_invitation = true }
      send_invitation
      redirect_to edit_admin_user_path(@user), status: :see_other, notice: "Sent a new link to #{@user.email}."
    end

    private

    def find_user
      @user = User.find(params.expect(:id))
    end

    def user_params
      params.expect(user: [:email, :first_name, :last_name, :institution, :role, { sponsor_ids: [] }])
            .tap { |attributes| attributes[:role] = attributes[:role].presence if attributes.key?(:role) }
    end

    def search_sql
      %w[email first_name last_name institution].map { |column| "users.#{column} ILIKE :q" }.join(' OR ')
    end

    # Sent straight away rather than through the job queue, so the token is not stored in the queue's table
    def send_invitation
      AccountMailer.invitation(@user, @user.raw_invitation_token, site: subdomain_from_request,
                                                                  invited_by: current_user).deliver_now
      @user.current_invitation.update!(invitation_sent_at: Time.current) # the link's validity starts now
    end
  end
end

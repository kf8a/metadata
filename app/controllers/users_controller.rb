# frozen_string_literal: true

# handler interaction with the user class
class UsersController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  protect_from_forgery except: :show

  def index; end

  def create
    @user = User.new user_params
    @invite = Invite.find_redeemable(params[:invite_code])

    if @user.save
      redeem if @invite

      redirect_to(url_after_create)
    else
      render :new
    end
  end

  def new
    @invite_code = params[:invite_code]
    super
  end

  def show
    logger.info "Current user (usercontroller) #{current_user}"
    render head: :not_acceptable if request.format == :html
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def redeem
    @invite.redeemed!
    return unless @invite.glbrc_member?

    sponsor = Sponsor.find_by(name: 'glbrc')
    Membership.create(user: @user, sponsor: sponsor)
  end
end

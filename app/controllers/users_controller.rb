# handler interaction with the user class
class UsersController < Clearance::UsersController
  before_action :require_login, except: [:index, :show]
  protect_from_forgery except: :show

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
   return if request.format == :json
   render :nothing => true, :status => 406
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def redeem
    @invite.redeemed!
    if @invite.glbrc_member?
      sponsor = Sponsor.find_by_name('glbrc')
      Membership.create(user: @user, sponsor: sponsor)
    end
  end
end

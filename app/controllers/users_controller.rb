class UsersController < Clearance::UsersController

  def create
    @user = User.new params[:user]
    @invite = Invite.find_redeemable(params[:invite_code])

    if @user.save
      if @invite
        @invite.redeemed!
        if @invite.glbrc_member?
          sponsor = Sponsor.find_by_name('glbrc')
          Membership.create(:user => @user, :sponsor => sponsor)
        end
      end

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
  end
end

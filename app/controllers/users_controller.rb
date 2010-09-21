class UsersController < Clearance::UsersController
  layout :site_layout
  
  def create
    @user = ::User.new params[:user]
    invite_code = params[:invite_code]
    @invite = Invite.find_redeemable(invite_code)

    if @user.save
      if invite_code && @invite
        @invite.redeemed!
        if @invite.glbrc_member?
          @user.sponsors << Sponsor.find_by_name('glbrc')
          @user.save
        end
      end
      
      flash_notice_after_create
      redirect_to(url_after_create)
    else
      render :template => 'users/new'
    end
  end
end

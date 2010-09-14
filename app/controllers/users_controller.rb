class UsersController < Clearance::UsersController
  layout :site_layout
  
  def create
    @user = ::User.new params[:user]
    if @user.save
      flash_notice_after_create
      redirect_to(url_after_create)
    else
      render :template => 'users/new'
    end
  end
end

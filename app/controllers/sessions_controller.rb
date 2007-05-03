class SessionsController < ApplicationController

  skip_before_filter :login_required
  
  def create
    open_id_authentication(params[:openid_url])
  end
  
  def new
    store_location
  end
  
  def delete
    logout
  end
  
 protected
  def open_id_authentication(identity_url)
      authenticate_with_open_id(identity_url) do |status, identity_url|
        if :successful
          if @current_user = Person.find_by_open_id(identity_url)
            successful_login
          else
            failed_login "Sorry, no user by that identity URL exists"
          end
        end
      end
    end

  private
    def successful_login
      login(@current_user.id)
      redirect_back_or_default
    end

    def failed_login(message)
      flash[:error] = message
      redirect_to(new_sessions_url)
    end
  
end

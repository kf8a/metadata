class SessionsController < Clearance::SessionsController
  
  layout :site_layout
  
  def new
    render_subdomain
  end

  def create
    if params[:session]
      session = params[:session]
      params[:openid_url] = session[:openid_url] unless session[:openid_url].empty?
    end
    if using_open_id?
      authenticate_with_openid
    else
      super    # let clearance handle it
    end
  end
  
  private
    
  def authenticate_with_openid
    @openid_url = params[:openid_url]

    # Pass optional :required and :optional keys to specify what sreg fields
    # you want. Be sure to yield registration, a third argument in the block.
    authenticate_with_open_id(@openid_url, :optional => [:email]) do |result, identity_url, reg|
       
      if result.successful?
        @user = ::User.find_by_identity_url(identity_url)
        logger.info @user
        if @user.nil?
          if reg['email'].present?
            # create account for user
            @user = ::User.new
            @user.email = reg['email']
            @user.identity_url = identity_url
            @user.encrypted_password = 'no password' # hack around validation
            @user.save
          else
            flash[:notice] = "We couldn't get your email address from your OpenId provider, please enter it to finish"
            # didn't get email from openid, need to prompt for it
            redirect_to new_user_path(:identity_url => identity_url)
            return
          end
        end

        sign_user_in(@user)
        redirect_back_or url_after_create
      else
        deny_access(result.message ||
        "Sorry, could not authenticate #{identity_url}")
      end
    end

  end
  
  private
  
  def return_to
    '/datatables'
  end
  
  def set_title
    @title = @subdomain_request.upcase
  end
  
end

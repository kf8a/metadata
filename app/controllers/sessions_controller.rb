# create new session for logging in
class SessionsController < Clearance::SessionsController
  def new; end

  def create
    # set the default user if blank or 'lter'
    if params[:session]
      session = params[:session]
      logger.info "email" session[:email]
      if session[:email].empty? || session[:email].casecmp('lter').zero?
        params[:session][:email] = 'lter@kbs.edu'
      end
    end

    super # let clearance handle it
  end

  private

  def set_title
    @title = @subdomain_request.upcase
  end
end

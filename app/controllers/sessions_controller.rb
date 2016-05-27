class SessionsController < Clearance::SessionsController
  def new
  end

  def create
    if params[:session]
      session = params[:session]
    end
    # set the default user if blank or 'lter'
    if params[:session]
      session = params[:session]
      logger.info(session)
      logger.info(session[:email])
      if session[:email].empty? || session[:email].casecmp('lter') == 0
        params[:session][:email] = 'lter@kbs.edu'
      end
      logger.info(session)
      logger.info(session[:email])
    end
    super # let clearance handle it
  end

  private

  def set_title
    @title = @subdomain_request.upcase
  end
end

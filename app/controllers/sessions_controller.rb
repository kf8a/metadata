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
      if session[:email].empty? or session[:email].downcase == 'lter'
        params[:session][:email] = 'lter@kbs.edu'
      end
    end
    super    # let clearance handle it
  end

  private

  def set_title
    @title = @subdomain_request.upcase
  end

end

# frozen_string_literal: true

# create new session for logging in
class SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, only: :create

  # def new
  #   redirect_to @oauth_client.auth_code.authorize_url
  #   # if @subdomain_request == 'glbrc'
  #   #   # auth against glbrc
  #   #   redirect_to @oauth_client.auth_code.authorize_url
  #   # else
  #   #   super
  #   # end
  # end

  def create
    # set the default user if blank or 'lter'
    if params[:session]
      session = params[:session]
      logger.info "email #{session[:email]}"
      params[:session][:email] = 'lter@kbs.edu' if session[:email].empty? || session[:email].casecmp('lter').zero?
    end

    super # let devise handle it
  end

  private

  def set_title
    @title = @subdomain_request.upcase
  end
end

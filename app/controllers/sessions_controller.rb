# frozen_string_literal: true

JWT_ALGORITHM = 'RS256'
KEYS_URL      = '/adfs/discovery/keys'
BASE_URL      = 'https://login.glbrc.org'

# create new session for logging in
class SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, only: %i[create new]

  # https://login.glbrc.org/adfs/oauth2/authorize?client_id=11948d5b-7a4c-4a03-b8b1-eda14c14f220&redirect_uri=https%3A%2F%2Fdata.glbrc.org%2Fusers%2Fauth%2Fglbrc%2Fcallback&response_type=code&state=f33d8ad814abf87ac7996bdd6d92964a7e6239e298510f66',

  def initialize
    super
    @oauth_client = OAuth2::Client.new(Rails.configuration.x.oauth.client_id,
                                       Rails.configuration.x.oauth.client_secret,
                                       authorize_url: '/adfs/oauth2/authorize',
                                       site: Rails.configuration.x.oauth.idp_url,
                                       token_url: '/adfs/oauth2/token',
                                       redirect_uri: Rails.configuration.x.oauth.redirect_uri,
                                       ssl: { verify: !Rails.env.development? })
    @public_keys = public_keys
    logger.info @public_keys
  end

  def new
    redirect_to @oauth_client.auth_code.authorize_url
    # if @subdomain_request == 'glbrc'
    #   # auth against glbrc
    #   redirect_to @oauth_client.auth_code.authorize_url
    # else
    #   super
    # end
  end

  def create
    # set the default user if blank or 'lter'
    if params[:session]
      session = params[:session]
      logger.info "email #{session[:email]}"
      params[:session][:email] = 'lter@kbs.edu' if session[:email].empty? || session[:email].casecmp('lter').zero?
    end

    super # let devise handle it
  end

  def callback
    logger.info "in callback"
    logger.info params
    # Make a call to exchange the authorization_code for an access_token
    response = @oauth_client.auth_code.get_token(params[:code])

    # Extract the access token from the response
    token = response.to_hash[:access_token]

    logger.info "Token: #{token}"
    logger.info "public: #{@public_keys}"
    logger.info JWT.decode(token, nil, true, { algorithms: ['RS256'] }) do |header|
      ::JWT::JWK::KeyFinder.new(jwks: @public_keys).key_for(header['x5t'])
    end

    # logger.info JWT.decode(token, nil, true, { algorithms: ['RSA'], jwks: @public_keys})

    # # Decode the token
    # begin
    #   decoded = TokenDecoder.new(token, @oauth_client.id).decode
    # rescue Exception => e
    #   "An unexpected exception occurred: #{e.inspect}"
    #   head :forbidden
    #   return
    # end
    #
    # # Set the token on the user session
    # session[:user_jwt] = { value: decoded, httponly: true }
    # logger.info session

    raise

    # redirect_to "/datatables/162"
  end

  def decode(token, keys)
    logger.info JWT.decode(token, nil, true, { algorithms: ['RS256'] }) do |header|
      p header
      ::JWT::JWK::KeyFinder.new(jwks: keys).key_for(header['x5t'])
    end
  end

  private

  def public_keys
    response = RestClient.get "#{BASE_URL}#{KEYS_URL}", { accept: :json }

    raise "Endpoint returned status code: #{response.code} with body: #{response.body}" unless response.code == 200

    SymbolizeHashKeys.deep_symbolize_keys(JSON.parse(response.body))
  rescue => e
    raise KeyError.new("Unable to obtain public keys - #{e.message}")
  end


  def set_title
    @title = @subdomain_request.upcase
  end
end

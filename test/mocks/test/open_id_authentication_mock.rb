module OpenIdAuthentication 

  EXTENSION_FIELDS = {'email' => 'user@somedomain.com',
                      'nickname' => 'cool_user',
                      'country' => 'US',
                      'postcode' => '12345',
                      'fullname' => 'Cool User',
                      'dob' => '1970-04-01',
                      'language' => 'en',
                      'timezone' => 'America/New_York'}     

  protected

    def authenticate_with_open_id(identity_url = params[:openid_url], fields = {}) #:doc:
      identity_url = normalize_url(identity_url)
      if User.find_by_openid_url(identity_url) || identity_url.include?('good')
        # Don't process registration fields unless it is requested.
        unless identity_url.include?('blank') || (fields[:required].nil? && fields[:optional].nil?)
          extension_response_fields = {}
          # fields[:required].each do |field|
          #   extension_response_fields[field.to_s] = EXTENSION_FIELDS[field.to_s]
          # end  
          fields[:optional].each do |field|
            extension_response_fields[field.to_s] = EXTENSION_FIELDS[field.to_s]
          end
        end

        yield Result[:successful], identity_url , extension_response_fields
      else
        logger.info "OpenID authentication failed: #{identity_url}" 
        yield Result[:failed], identity_url, nil
      end
    end

  private

    def add_simple_registration_fields(open_id_response, fields)
      open_id_response.add_extension_arg('sreg', 'required', [ fields[:required] ].flatten * ',') if fields[:required]
      open_id_response.add_extension_arg('sreg', 'optional', [ fields[:optional] ].flatten * ',') if fields[:optional]
    end
end
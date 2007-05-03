module OpenIdAuthentication
  OPEN_ID_AUTHENTICATION_DIR = RAILS_ROOT + "/tmp/openids"

  class Result
    ERROR_MESSAGES = {
      :missing    => "Sorry, the OpenID server couldn't be found",
      :canceled   => "OpenID verification was canceled",
      :failed     => "Sorry, the OpenID verification failed"
    }
    
    def self.[](code)
      new(code)
    end
    
    def initialize(code)
      @code = code
    end
    
    def ===(code)
      if code == :unsuccessful && unsuccessful?
        true
      else
        @code == code
      end
    end
    
    ERROR_MESSAGES.keys.each { |state| define_method("#{state}?") { @code == state } }

    def successful?
      @code == :successful
    end

    def unsuccessful?
      ERROR_MESSAGES.keys.include?(@code)
    end
    
    def message
      ERROR_MESSAGES[@code]
    end
  end

  def self.normalize_url(url)
    url = url.downcase
  
    case url
    when %r{^https?://[^/]+/[^/]*}
      url # already normalized
    when %r{^https?://[^/]+$}
      url + "/"
    when %r{^[.\d\w]+/.*$}
      "http://" + url
    when %r{^[.\d\w]+$}
      "http://" + url + "/"
    else
      raise "Unable to normalize: #{url}"
    end
  end


  protected
    def normalize_url(url)
      OpenIdAuthentication.normalize_url(url)
    end

    # The parameter name of "openid_url" is used rather than the Rails convention "open_id_url"
    # because that's what the specification dictates in order to get browser auto-complete working across sites
    def using_open_id?(identity_url = params[:openid_url]) #:doc:
      !identity_url.blank? || params[:open_id_complete]
    end

    def authenticate_with_open_id(identity_url = params[:openid_url], fields = {}, &block) #:doc:
      if params[:open_id_complete].nil?
        begin_open_id_authentication(normalize_url(identity_url), fields, &block)
      else
        complete_open_id_authentication(&block)
      end
    end


  private
    def begin_open_id_authentication(identity_url, fields = {})
      open_id_response = timeout_protection_from_identity_server { open_id_consumer.begin(identity_url) }

      case open_id_response.status
      when OpenID::FAILURE
        yield Result[:missing], identity_url, nil
      when OpenID::SUCCESS
        add_simple_registration_fields(open_id_response, fields)
        redirect_to(open_id_redirect_url(open_id_response))
      end
    end
  
    def complete_open_id_authentication
      open_id_response = timeout_protection_from_identity_server { open_id_consumer.complete(params) }
      identity_url     = normalize_url(open_id_response.identity_url) if open_id_response.identity_url

      case open_id_response.status
      when OpenID::CANCEL
        yield Result[:canceled], identity_url, nil
      when OpenID::FAILURE
        logger.info "OpenID authentication failed: #{open_id_response.msg}"
        yield Result[:failed], identity_url, nil
      when OpenID::SUCCESS
        yield Result[:successful], identity_url, open_id_response.extension_response('sreg')
      end      
    end

    def open_id_consumer
      OpenID::Consumer.new(session, OpenID::FilesystemStore.new(OPEN_ID_AUTHENTICATION_DIR))
    end


    def add_simple_registration_fields(open_id_response, fields)
      open_id_response.add_extension_arg('sreg', 'required', [ fields[:required] ].flatten * ',') if fields[:required]
      open_id_response.add_extension_arg('sreg', 'optional', [ fields[:optional] ].flatten * ',') if fields[:optional]
    end
    
    def open_id_redirect_url(open_id_response)
      return_url = request.protocol + request.host_with_port + request.relative_url_root + request.path
      open_id_response.redirect_url(
        request.protocol + request.host_with_port + "/",
        open_id_response.return_to("#{return_url}?open_id_complete=1")
      )     
    end

    def timeout_protection_from_identity_server
      yield
    rescue Timeout::Error
      Class.new do
        def status
          OpenID::FAILURE
        end
        
        def msg
          "Identity server timed out"
        end
      end.new
    end
end
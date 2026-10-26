# frozen_string_literal: true

# create new session for logging in
class SessionsController < Devise::SessionsController
  private

  def set_title
    @title = @subdomain_request.upcase
  end
end

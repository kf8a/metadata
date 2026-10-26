# frozen_string_literal: true

# create new session for logging in
class SessionsController < Devise::SessionsController
  # create is inherited from Devise::SessionsController
  skip_before_action :verify_authenticity_token, only: :create # rubocop:disable Rails/LexicallyScopedActionFilter

  private

  def set_title
    @title = @subdomain_request.upcase
  end
end

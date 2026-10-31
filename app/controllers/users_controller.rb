# frozen_string_literal: true

# handler interaction with the user class
class UsersController < ApplicationController
  before_action :authenticate_user!, except: %i[show]

  def show
    logger.info "Current user (usercontroller) #{current_user}"
    logger.info request.format
    head :bad_request unless request.format == 'text/javascript'
  end
end

# frozen_string_literal: true

# callback controller to be called from
# the glbrc single sign on server
class GlbrcAuthenticationController < ApplicationController
  def callback(params)
    logger.info "in callback"
    logger.info params
  end
end

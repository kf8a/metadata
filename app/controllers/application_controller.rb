# frozen_string_literal: true

require 'subdomain_resolver'

class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true, with: :exception


  include Clearance::Controller
  # include CentralLogger::Filter

  layout :site_layout

  before_action :set_crumbs, :set_subdomain_request, :extra_views, :set_title
  before_action :require_login, except: %i[index show suggest search]

  respond_to :html, :json

  private

  def extra_views
    prepend_view_path SubdomainResolver.new(@subdomain_request)
  end

  def admin?
    logger.info "current user: #{current_user}"
    unless current_user.try(:role) == 'admin'
      flash[:notice] = 'You must be signed in as an administrator'\
                      ' in order to access this page'
      deny_access
      return false
    end
  end

  def set_crumbs
    @crumbs = []
  end

  def set_subdomain_request
    @subdomain_request = request_subdomain(params[:requested_subdomain])
  end

  def set_title
    @title = @subdomain_request.upcase
  end

  def site_layout
    request_subdomain(params[:requested_subdomain])
  end

  def request_subdomain(requested_subdomain)
    valid_subdomain?(requested_subdomain) ? requested_subdomain : subdomain_from_request
  end

  def subdomain_from_request
    request.host.downcase.include?('glbrc') ? 'glbrc' : 'lter'
  end

  def valid_subdomain?(subdomain)
    %w[lter glbrc].include?(subdomain)
  end

  def website
    @website ||= Website.find_by(name: @subdomain_request) || Website.first
  end
end

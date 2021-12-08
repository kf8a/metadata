# frozen_string_literal: true

require 'logger'

class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def glbrc
    if (@user = User.from_omniauth(request.env["omniauth.auth"]))
      sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "GLBRC") if is_navigational_format?
    else
      set_flash_message(:error, :failure, kind: "GLBRC", reason: "you have not been granted access.")
      session["devise.glbrc_data"] = request.env["omniauth.auth"]
      redirect_to '/'
    end
  end

  def after_omniauth_failure_path_for(_scope)
    '/'
  end
end

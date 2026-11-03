# frozen_string_literal: true

module Admin
  # For the admin user pages
  module UsersHelper
    def user_status(user)
      if user.invitation_pending? then 'Has not set a password yet'
      elsif user.access_locked? then 'Locked after too many failed sign-ins'
      elsif user.last_sign_in_at then "Last signed in #{user.last_sign_in_at.to_date.to_fs(:long)}"
      else 'Never signed in'
      end
    end
  end
end

# frozen_string_literal: true

module Admin
  # For the admin user pages
  module UsersHelper
    def user_status(user)
      if user.invitation_pending? then 'Has not set a password yet'
      elsif user.access_locked? then 'Locked after too many failed sign-ins'
      elsif user.last_sign_in_at then "Last signed in #{admin_date(user.last_sign_in_at)}"
      else 'Never signed in'
      end
    end

    # "March 5, 2019"
    def admin_date(time)
      time&.strftime('%B %-d, %Y')
    end
  end
end

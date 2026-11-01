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

    # How long an account has existed, in whole years once past one, else whole months: "2 years",
    # "5 months", "under a month". Blank for old accounts without a creation date.
    def membership_length(user)
      return unless user.created_at

      months = whole_months_since(user.created_at.to_date)
      if months >= 12 then pluralize(months / 12, 'year')
      elsif months.positive? then pluralize(months, 'month')
      else 'under a month'
      end
    end

    def whole_months_since(date)
      today = Date.current
      months = ((today.year - date.year) * 12) + today.month - date.month
      today.day < date.day ? months - 1 : months
    end
  end
end

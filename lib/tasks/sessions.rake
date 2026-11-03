# frozen_string_literal: true

namespace :sessions do
  desc 'Delete sessions idle past the sign-in timeout plus a day (runs daily as SessionsTrimJob)'
  task trim: :environment do
    SessionsTrimJob.perform_now
  end
end

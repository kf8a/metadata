# frozen_string_literal: true

# Per-client request limits, enforced by Rack::Attack before a request reaches Rails.
#
# The client is the request's IP (nginx passes the real one on in X-Forwarded-For; Rack ignores that header
# from anything but a trusted proxy). Counts live in Rails.cache, which is memcached in production, so every
# Puma worker shares them. If memcached is down the counts are lost and nothing is limited.
#
#   requests/ip   every request except assets: PER_SECOND a second
#   logins/ip     signing in and the password, unlock and invitation links: PER_MINUTE a minute
#   costly/ip     searches, file downloads and data queries: PER_MINUTE a minute
#
# The limits start here and can be changed without a deploy with RATE_LIMIT_PER_SECOND and
# RATE_LIMIT_PER_MINUTE, or switched off with RATE_LIMITING=off, in the environment of the app's service.
module RateLimits
  PER_SECOND = ENV.fetch('RATE_LIMIT_PER_SECOND', 8).to_i
  PER_MINUTE = ENV.fetch('RATE_LIMIT_PER_MINUTE', 15).to_i

  LOGIN_PATHS = %r{\A/users/(sign_in|password|unlock|invitation|auth)}
  DOWNLOAD_PATHS = %r{\A/(pub/|(citations|abstracts|protocols)/\d+/download)}
  DATA_PATHS = %r{\A(/datatables/\d+\.(csv|eml)|/datasets(/\d+)?\.eml|/visualizations/)}
  SEARCH_PATHS = %r{\A/(datatables/(search|suggest)|citations/(search|filtered))}

  def self.asset?(path)
    path.start_with?("#{Rails.application.config.assets.prefix}/", '/favicon.ico')
  end

  def self.costly?(path)
    [DOWNLOAD_PATHS, DATA_PATHS, SEARCH_PATHS].any? { |paths| paths.match?(path) }
  end
end

Rack::Attack.enabled = ENV['RATE_LIMITING'] != 'off' && !Rails.env.test? # the specs that test it turn it on
Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new if Rails.env.test?

Rack::Attack.throttle('requests/ip', limit: RateLimits::PER_SECOND, period: 1.second) do |request|
  request.ip unless RateLimits.asset?(request.path)
end

Rack::Attack.throttle('logins/ip', limit: RateLimits::PER_MINUTE, period: 1.minute) do |request|
  request.ip if RateLimits::LOGIN_PATHS.match?(request.path)
end

Rack::Attack.throttle('costly/ip', limit: RateLimits::PER_MINUTE, period: 1.minute) do |request|
  request.ip if RateLimits.costly?(request.path)
end

Rack::Attack.throttled_responder = lambda do |request|
  match = request.env['rack.attack.match_data']
  retry_after = [match[:period] - (match[:epoch_time] % match[:period]), 1].max
  [429, { 'content-type' => 'text/plain', 'retry-after' => retry_after.to_s },
   ["Too many requests. Please slow down and try again in #{retry_after} seconds.\n"]]
end

# The path only, not the query string, which can carry tokens
ActiveSupport::Notifications.subscribe('throttle.rack_attack') do |_name, _start, _finish, _id, payload|
  request = payload[:request]
  Rails.logger.warn "[rack-attack] #{request.env['rack.attack.matched']} limit reached: " \
                    "#{request.ip} #{request.request_method} #{request.path}"
end

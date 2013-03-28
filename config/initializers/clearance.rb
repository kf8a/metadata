Clearance.configure do |config|
  config.cookie_expiration = lambda { 1.month.from_now.utc }
  config.mailer_sender = 'data@glbrc.kbs.msu.edu'
end

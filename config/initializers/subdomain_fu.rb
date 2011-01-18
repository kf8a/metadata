SubdomainFu.configure do |config|
  config.tld_sizes = {:development => 0,
                       :cucumber => 0,
                       :test => 0,
                       :production => 3}
end

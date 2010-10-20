# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Metadata::Application.initialize!

#Maybe these belong here
SubdomainFu.configure do |config|
  config.tld_sizes = {:development => 0,
                       :cucumber => 0,
                       :test => 0,
                       :production => 3}
end


OpenIdAuthentication.store = :file

ActionController::Base.cache_store = :file_store, "tmp/cache" #"/path/to/cache/directory"
Struct.new('Crumb', :url, :name)
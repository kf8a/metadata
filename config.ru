# This file is used by Rack-based servers to start the application.
# require 'rack'
# require 'prometheus/client/rack/collector'
# require 'prometheus/client/rack/exporter'

# use Prometheus::Client::Rack::Collector
# use Prometheus::Client::Rack::Exporter


require ::File.expand_path('../config/environment',  __FILE__)
run Metadata::Application


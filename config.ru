# This file is used by Rack-based servers to start the application.
require 'rack'
require 'prometheus/client/rack/collector'
require 'prometheus/client/rack/exporter'

use Rack::Deflater, if: ->(env, status, headers, body) { body.any? && body[0].length > 512 }
use Prometheus::Client::Rack::Collector
use Prometheus::Client::Rack::Exporter

run ->(env) { [200, {'Content-Type' => 'text/html'}, ['OK']] }

require ::File.expand_path('../config/environment',  __FILE__)
run Metadata::Application


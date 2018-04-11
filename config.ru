# This file is used by Rack-based servers to start the application.

require 'rack'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

require ::File.expand_path('../config/environment',  __FILE__)
run Metadata::Application

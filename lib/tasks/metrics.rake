require 'metric_fu'

MetricFu::Configuration.run do |config|
  #define what metrics you want to use
  config.metrics  = [:churn, :flay, :rails_best_practices, :reek, :roodi, :stats]
  config.graphs   = [:flay, :rails_best_practices, :reek, :roodi, :stats]
end

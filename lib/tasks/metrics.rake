require 'metric_fu'

MetricFu::Configuration.run do |config|
  #define what metrics you want to use
  config.metrics = [:flay, :hotspots, :rails_best_practices, :reek, :stats]
  config.graphs = [:flay, :rails_best_practices, :reek, :stats]
  config.verbose = true #helpful to see which things are causing errors
end

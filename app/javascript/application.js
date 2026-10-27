// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import "@hotwired/turbo-rails";
import "controllers";

// Legacy graphs (score cards and datatable QC), still on jQuery and Protovis
import "legacy/protovis-d3.2";
import "legacy/proto-graphs";
import "legacy/scores";

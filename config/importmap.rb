# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
# Stimulus 3.2.2, served from the stimulus-rails gem rather than a third-party CDN
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin_all_from "app/javascript/controllers", under: "controllers"
# d3 7.9.0, vendored as a single ES module (see the header of vendor/javascript/d3.js)
pin "d3", to: "d3.js"

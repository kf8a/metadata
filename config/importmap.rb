# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
# Stimulus 3.2.2, served from the stimulus-rails gem rather than a third-party CDN
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin_all_from "app/javascript/controllers", under: "controllers"
# After your existing pins — pick a namespace that won’t clash with npm-style names:
pin_all_from 'app/assets/javascripts', under: 'legacy', to: ""

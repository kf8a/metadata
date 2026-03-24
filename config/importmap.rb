# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "https://ga.jspm.io/npm:@hotwired/stimulus@3.2.2/dist/stimulus.js"
pin_all_from "app/javascript/controllers", under: "controllers"
# After your existing pins — pick a namespace that won’t clash with npm-style names:
pin_all_from 'app/assets/javascripts', under: 'legacy', to: ""

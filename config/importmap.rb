# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin_all_from 'app/javascript/modules', under: 'modules'
pin "chart.js", to: "https://ga.jspm.io/npm:chart.js@4.2.0/dist/chart.js" # @4.4.4
pin "@kurkle/color", to: "@kurkle--color.js" # @0.3.2

// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "chartkick"
import "./controllers"

// Polaris
import { registerPolarisControllers } from "polaris-view-components"
registerPolarisControllers(Stimulus)

// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "./controllers"
import "chartkick"

// Polaris
import { registerPolarisControllers } from "polaris-view-components"
registerPolarisControllers(Stimulus)

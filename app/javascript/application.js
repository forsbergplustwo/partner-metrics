// Bundled by esbuild (jsbundling-rails). Output is served by Propshaft from app/assets/builds.
import "@hotwired/turbo-rails"
import "./controllers"
import "chartkick"
import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

// Polaris
import { registerPolarisControllers } from "polaris-view-components"
registerPolarisControllers(Stimulus)

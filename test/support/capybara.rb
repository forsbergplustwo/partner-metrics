# frozen_string_literal: true

require "capybara"

Capybara.server = :puma, { Silent: true }
Capybara.default_max_wait_time = 15

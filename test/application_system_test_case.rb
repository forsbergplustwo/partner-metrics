require "test_helper"
require_relative "support/capybara"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include Devise::Test::IntegrationHelpers

  DRIVER = (ENV["HEADLESS"] == "false") ? :chrome : :headless_chrome
  driven_by :selenium, using: DRIVER, screen_size: [1400, 1400]

  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end

  parallelize_teardown do |i|
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end

  def attach_to_import(filename)
    path = Rails.root.join("test/fixtures/files/#{filename}")
    input = all("#import_payouts_file", visible: false)[1]

    attach_file(input, path)
  end
end

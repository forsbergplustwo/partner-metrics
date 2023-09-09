class Payment < ApplicationRecord
  YEARS_TO_IMPORT = 4.years.freeze
  UNKNOWN_APP_TITLE = "Unknown".freeze

  belongs_to :user
  belongs_to :import

  class << self
    def by_optional_app_title(app_title)
      app_title.blank? ? all : where(app_title: app_title)
    end

    def default_start_date
      YEARS_TO_IMPORT.ago.to_date
    end
  end
end

# TODO: Refactor this class to be more readable and maintainable
# Move the logic for calculating the metrics into a metric::calculator PORO model

class Payment < ApplicationRecord
  YEARS_TO_IMPORT = 4.years.freeze

  UNKNOWN_APP_TITLE = "Unknown".freeze

  belongs_to :user
  belongs_to :import

  def self.default_start_date
    YEARS_TO_IMPORT.ago.to_date
  end
end

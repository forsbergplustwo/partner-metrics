class Payment < ApplicationRecord
  UNKNOWN_APP_TITLE = "Unknown".freeze

  belongs_to :user
  belongs_to :import

  class << self
    def by_optional_app_title(app_title)
      app_title.blank? ? all : where(app_title: app_title)
    end

    def by_date_and_period(date:, period:)
      previous_period = date - period.days + 1
      where(payment_date: previous_period.beginning_of_day..date.end_of_day)
    end
  end
end

class Payment < ApplicationRecord
  UNKNOWN_APP_TITLE = "Unknown".freeze

  belongs_to :user
  belongs_to :import

  class << self
    def by_optional_app_title(app_title)
      app_title.blank? ? all : where(app_title: app_title)
    end
  end
end

class ApplicationMailer < ActionMailer::Base
  default from: -> { default_from }
  layout "mailer"

  private

  def default_from
    Rails.application.credentials[:action_mailer][:email_from_address]
  end
end

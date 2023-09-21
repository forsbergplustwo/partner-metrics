class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials[:action_mailer][:email_from_address]
  layout "mailer"
end

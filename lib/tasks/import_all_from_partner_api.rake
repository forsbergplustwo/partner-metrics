desc "Import transactions for existing users, with partner api credentials"
task import_all_from_partner_api: :environment do
  User.find_each do |user|
    if user.partner_api_access_token.present? && user.partner_api_organization_id.present? # Maybe? && user.last_sign_in_at > 90.days.ago
      Resque.enqueue(ImportWorker, user.id)
    end
  end
end

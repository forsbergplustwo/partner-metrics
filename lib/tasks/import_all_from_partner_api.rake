desc "Import transactions for existing users, with partner api credentials"
task import_all_from_partner_api: :environment do
  User.find_each do |user|
    if user.has_partner_api_credentials? && !user.partner_api_errors.include?("Unauthorized")
      user.imports.create(source: Import::SHOPIFY_PAYMENTS_API_SOURCE)
    end
  end
end

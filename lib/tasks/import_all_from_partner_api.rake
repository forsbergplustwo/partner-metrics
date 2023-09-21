desc "Import transactions for existing users, with partner api credentials"
task import_all_from_partner_api: :environment do
  User.find_each do |user|
    if user.partner_api_credential&.valid_status?
      user.imports.create(source: Import.sources[:shopify_payments_api])
    end
  end
end

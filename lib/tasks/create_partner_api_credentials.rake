desc "Creates the inital import for all users, so all historical payments and metrics have an import"
task create_partner_api_credentials: :environment do
  User.find_each do |user|
    if user.partner_api_access_token.present? && user.partner_api_organization_id.present? && !user.partner_api_errors&.include?("Unauthorized")
      if user.partner_api_credential.blank?
        user.create_partner_api_credential(
          organization_id: user.partner_api_organization_id,
          access_token: user.partner_api_access_token
        )
      end
    end
  end
end

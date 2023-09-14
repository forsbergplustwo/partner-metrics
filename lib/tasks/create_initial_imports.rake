desc "Creates the inital import for all users, so all historical payments and metrics have an import"
task create_initial_imports: :environment do
  User.find_each do |user|
    import = user.imports.create!(
      source: Import.sources[:shopify_payments_api]
    )
    user.metrics.update_all(import_id: import.id) if user.metrics.any?
    user.payments.update_all(import_id: import.id) if user.payments.any?
    import.completed!
  end
end

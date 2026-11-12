# frozen_string_literal: true

desc "Creates the inital import for all users, so all historical payments and metrics have an import"
task create_initial_imports: :environment do
  User.find_each do |user|
    import = user.imports.create!(
      source: Import.sources[:shopify_payments_api],
      status: Import.statuses[:completed],
    )
    user.metrics.update_all(import_id: import.id) if user.metrics.any? # rubocop:disable Rails/SkipsModelValidations -- backfill skips callbacks on purpose
    user.payments.update_all(import_id: import.id) if user.payments.any? # rubocop:disable Rails/SkipsModelValidations -- backfill skips callbacks on purpose
  end
end

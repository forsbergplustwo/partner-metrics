class Import < ApplicationRecord
  belongs_to :user
  has_many :payments, dependent: :delete_all
  has_many :metrics, dependent: :delete_all
  has_one_attached :payouts_file, dependent: :destroy

  ACCEPTED_FILE_TYPES = %w[text/csv application/zip].freeze

  IMPORT_FILE_SOURCE = "import_file"
  SHOPIFY_PAYMENTS_API_SOURCE = "shopify_payments_api"
  # SHOPIFY_APP_EVENTS_API_SOURCE = "shopify_app_events_api"

  enum source: {
    import_file: IMPORT_FILE_SOURCE,
    shopify_payments_api: SHOPIFY_PAYMENTS_API_SOURCE
    # shopify_app_events_api: SHOPIFY_APP_EVENTS_API_SOURCE
  }

  enum status: {
    draft: "draft",
    scheduled: "scheduled",
    processing: "processing",
    calculating: "calculating",
    completed: "completed",
    failed: "failed"
  }, _default: "draft"

  validates :payouts_file, attached: true, content_type: ACCEPTED_FILE_TYPES, if: -> { import_file? }
  validates :source, presence: true
  validates :status, presence: true

  after_create_commit :schedule!
  after_update_commit :broadcast_status_change, if: -> { saved_change_to_status? }

  def schedule!
    scheduled!
    ImportJob.perform_later(import: self)
  end

  def broadcast_status_change
    broadcast_replace_to(
      [user, :imports],
      target: "#{id}_status",
      partial: "imports/status",
      locals: {import: self}
    )
  end
end

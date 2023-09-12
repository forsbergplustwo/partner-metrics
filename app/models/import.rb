class Import < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :user
  has_many :payments, dependent: :delete_all
  has_many :metrics, dependent: :delete_all
  has_one_attached :payouts_file, dependent: :destroy
  has_one :partner_api_credential, through: :user

  ACCEPTED_FILE_TYPES = %w[text/csv application/zip].freeze

  enum source: {
    csv_file: "csv_file",
    shopify_payments_api: "shopify_payments_api"
    # shopify_app_events_api: "shopify_app_events_api"
  }, _suffix: true

  enum status: {
    draft: "draft",
    scheduled: "scheduled",
    importing: "importing",
    calculating: "calculating",
    completed: "completed",
    failed: "failed"
  }, _default: "draft"

  validates :payouts_file, attached: true, content_type: ACCEPTED_FILE_TYPES, if: -> { csv_file_source? }
  validates :source, presence: true, inclusion: {in: sources.keys}
  validates :status, presence: true, inclusion: {in: statuses.keys}

  after_create_commit :schedule
  after_update_commit :broadcast_details_update
  after_update_commit :broadcast_status_update, if: -> { saved_change_to_status? }

  scope :in_progress, -> { where(status: %i[scheduled importing calculating]) }

  def schedule
    scheduled!
    ImportPaymentsJob.perform_later(import: self)
  end

  def import
    importing!
    Import::Payments.new(import: self).import!
    imported
  end

  def imported
    CalculateMetricsJob.perform_later(import: self)
  end

  def calculate
    calculating!
    Import::Metrics.new(import: self).calculate!
    completed!
  end

  def source_adaptor
    csv_file_source? ? Import::Adaptor::CsvFile : Import::Adaptor::ShopifyPaymentsApi
  end

  private

  def broadcast_details_update
    broadcast_replace_to(
      [user, :imports],
      target: dom_id(self, :details),
      partial: "imports/import",
      locals: {import: self}
    )
  end

  def broadcast_status_update
    broadcast_replace_to(
      [user, :imports],
      target: dom_id(self, :status),
      partial: "imports/status",
      locals: {import: self}
    )
  end
end

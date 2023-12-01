class Import < ApplicationRecord
  include ActionView::RecordIdentifier

  broadcasts_refreshes

  belongs_to :user, touch: true
  has_many :payments, dependent: :delete_all
  has_many :metrics, dependent: :delete_all
  has_one_attached :payouts_file, dependent: :destroy
  has_one :partner_api_credential, through: :user

  accepts_nested_attributes_for :user, update_only: true

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

  scope :in_progress, -> { where(status: %i[scheduled importing calculating]) }

  def retriable?
    shopify_payments_api_source? && failed? && user.imports.in_progress.empty?
  end

  def retry
    update(status: :draft)
    schedule
  end

  def schedule
    return unless draft?
    scheduled!
    ImportPaymentsJob.perform_later(import: self)
  end

  def import
    importing!
    Import::PaymentsProcessor.new(import: self).import!
    imported
  end

  def imported
    CalculateMetricsJob.perform_later(import: self)
  end

  def calculate
    calculating!
    Import::MetricsProcessor.new(import: self).calculate!
    completed!
  end

  def fail
    failed!
    payments.delete_all
    metrics.delete_all
  end

  def source_adaptor
    csv_file_source? ? Import::Adaptor::CsvFile : Import::Adaptor::ShopifyPaymentsApi
  end

  def import_payments_after_date
    max_allowed_ago = source_adaptor.const_get(:MAX_HISTORY).ago
    if user.newest_metric_date&.to_time.to_i < max_allowed_ago.to_i
      max_allowed_ago
    else
      user.newest_metric_date
    end
  end

  def import_metrics_after_date
    if user.newest_metric_date.present?
      user.newest_metric_date + 1.day
    else
      user.payments.minimum("payment_date")
    end
  end

  def import_metrics_before_date
    # Don't include the latest day, because it may not be complete
    user.payments.maximum(:payment_date) - 1.day
  end
end

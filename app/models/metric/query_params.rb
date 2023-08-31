class Metric::QueryParams
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :date, :date
  attribute :chart, :string
  attribute :period, :integer
  attribute :app, :string

  def to_param
    attributes.with_indifferent_access
  end
end

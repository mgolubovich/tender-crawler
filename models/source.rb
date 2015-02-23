# Source of tenders, in simple - site
# where tenders are published
class Source
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :tenders
  has_many :selectors
  has_many :cartridges

  # Source info
  field :name, type: String
  field :url, type: String
  field :comment, type: String

  # Service parameters
  field :is_active, type: Boolean
  field :source_type, type: Symbol, default: :auto
  field :last_imported_at, type: DateTime

  # Resque parameters
  field :resque_frequency, type: Integer
  field :deep_level, type: Integer, default: 100
  field :priority, type: Symbol, default: :middle

  scope :active, -> { where(is_active: true) }

  def load_cartridges
    cartridges.active.to_a
  end
end

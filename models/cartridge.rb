# Cartridge is a set of selectors
class Cartridge
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :source
  has_many :selectors
  has_many :page_managers

  field :name, type: String
  field :base_link_template, type: String
  field :base_list_template, type: String
  field :reaping_type, type: Symbol, default: :page # :page, :list, :mixed

  # Parametres for list type of reaping
  # Example: { "start" => 1, "end" => ''}
  field :list_offset, type: Hash

  field :tender_type, type: String

  field :is_active, type: Boolean, default: true

  field :delay_between_tenders, type: Integer, default: 0

  field :default_tender_values, type: Hash

  scope :active, where(is_active: true)

  # Returns true if selector with provided
  # value_type exists in cartridge
  def selector?(value_type)
    selectors.active.where(value_type: value_type).count.zero? ? false : true
  end

  # Returns scope of selectors with provided
  # value_type.
  def load_selectors(value_type)
    selectors.active.where(value_type: value_type).to_a
  end

  # Returns single selector object with
  # provided value_type.
  def load_selector(value_type)
    selectors.active.where(value_type: value_type).limit(1).first
  end

  def load_pm
    page_managers.first
  end

  def need_to_sleep?
    delay_between_tenders > 0
  end

  def tender_url(entity_id)
    self[:base_link_template].gsub('$entity_id', entity_id.to_s)
  end
end

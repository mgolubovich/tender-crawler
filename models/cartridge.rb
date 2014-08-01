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

  scope :active, where(is_active: true)
end

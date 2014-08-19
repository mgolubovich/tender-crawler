# Basically - result of parsing
class Tender
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveSupport::Callbacks

  belongs_to :source
  has_many :protocols

  set_callback :save, :before, :before_save

  class << self
    attr_accessor :data_fields_list
    attr_accessor :default_values_fields_list
  end

  @data_fields_list = [
    :id_by_source,
    :code_by_source,
    :title,
    :start_price,
    :tender_form,
    :customer_name,
    :customer_inn,
    :customer_address,
    :work_type,
    :documents
  ]

  @default_values_fields_list = [
    :title,
    :start_price,
    :tender_form,
    :customer_name,
    :customer_inn,
    :customer_address,
    :work_type
  ]


  # Timestamps, created_at and updated_at included via mongoid
  field :start_at, type: Time
  field :published_at, type: Time
  field :moderated_at, type: Time
  field :modified_at, type: Time

  # Source info
  # Code of tender based on source
  field :code_by_source, type: String

  # ID of tender on source-site
  field :id_by_source, type: String

  # Original link
  field :source_link, type: String

  # Group of tender (44, 223)
  field :group, type: Symbol

  # Actual tender info
  field :title, type: String
  field :start_price, type: Float
  field :tender_form, type: String
  field :customer_name, type: String
  field :customer_address, type: String
  field :customer_inn, type: String
  field :work_type, type: Array
  field :documents, type: Array

  # Fields for MySQL integration
  # Category of tender 0-5. Magic numbers. 0 - not needed. -1 - failed
  field :external_work_type, type: Integer

  # ID based on altasib_kladr_cities table
  field :external_city_id, type: Integer
  field :city_code, type: Integer

  # ID based on altasib_kladr_region
  field :external_region_id, type: Integer
  field :region_code, type: Integer

  # Not used tight now
  # field :external_db_id, type: Integer
  auto_increment :external_db_id, seed: 1_952_237

  field :status, type: Hash
  field :created_by, type: Symbol, default: :parser

  index({ source_id: 1, code_by_source: 1 }, { unique: true })
  index({ external_db_id: 1 }, { unique: true })

  def data_attr
    attrs = attributes.symbolize_keys
    attrs[:documents].map! { |d| d.symbolize_keys! } unless attrs[:documents].nil?
    attrs[:work_type].map! { |w| w.symbolize_keys! } unless attrs[:work_type].nil?
    attrs.select { |k| Tender.data_fields_list.include?(k) }
  end

  def md5
    Digest::MD5.hexdigest(data_attr.to_s)
  end

  def before_save
    self.code_by_source = self.id_by_source if self.code_by_source.to_s.empty?
    default_values
  end

  def default_values
    return nil if group.nil?
    cartridge = source.cartridges.where(tender_type: group).first
    return nil if cartridge.default_tender_values.to_s.empty?
    cartridge.default_tender_values.each do |field, value|
      attributes[field] = value if attributes[field].to_s.empty?
    end
  end
end

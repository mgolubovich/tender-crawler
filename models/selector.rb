# Selector is a structure which holds
# a set of params for parsing single
# or multiple values.
class Selector
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :source
  belongs_to :cartridge
  has_many :rules

  class << self
    attr_accessor :data_fields_list
  end

  @data_fields_list = [
    :ids_set,
    :doc_title,
    :doc_link,
    :work_type_code,
    :work_type_title
  ]

  # Type of field what this selector must extract.
  # Example: title, start_price etc
  # Also, this field used as mark for determing entity type of return value
  # Example - :ids_set, :protocol, :contractor
  field :value_type, type: Symbol

  # Type of value in ruby terms.
  # Example - :float, :integer, :string, :symbol, :time
  field :to_type, type: Symbol

  # Link where this selector must do it's work. Example: http://test.com/view?id=
  field :link_template, type: String

  # Xpath for capybara, location for target data
  field :xpath, type: String

  # Css selector path, location for target data
  field :css, type: String

  # Need to be set if target data contains in attribute
  # of selected tag instead of content.
  # Can be empty.
  field :attr, type: Symbol

  # Need to be set if we need to move cursor to get target data.
  # Example: {start: 0, end: 15}. Can be empty.
  field :offset, type: Hash

  # Regular expression what will be executed on target data before saving.
  # Can be empty.
  # {'mode' => 'match/gsub', pattern => "dfdf"}
  field :regexp, type: Hash

  # Format for parsed date
  field :date_format, type: String

  # Javascript code what must be executed on target page
  # before accessing target data.
  # Can be empty.
  field :js_code, type: String

  # Service field, used for sources with different setups of target data.
  # Zakupki, for a example.
  field :group, type: Symbol

  # Service field, used as activity flag of selector
  field :is_active, type: Boolean

  # Sorting number, used for optimisation of visits
  field :priority, type: Integer, default: 0

  # Service field, used as parameter for grappling method.
  # Shows which mode must be used.
  # Can be :single or :multiple
  field :grapple_mode, type: Symbol, default: :single

  scope :ids_set, where(value_type: :ids_set)
  scope :data_fields, not_in(value_type: Selector.data_fields_list)
  scope :active, where(is_active: true)

  def got_rule?
    rules.count.zero? ? false : true
  end

  # Regexp methods
  def regexp_mode?(mode)
    regexp['mode'].to_sym == mode
  end

  def regexp_valid?
    regexp['pattern'].empty? ? false : true
  end

  # Offset methods
  def offset_valid?
    offset['start'].zero? && offset['end'].zero? ? false : true
  end

  # General methods
  def field_valid?(field)
    self[field].to_s.blank? ? false : true
  end

  def value_type?(field)
    self[:value_type] == field ? true : false
  end
end

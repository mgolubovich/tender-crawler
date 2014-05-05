class Selector
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :source

  # Type of field what this selector must extract. Example: title, start_price etc
  field :value_type, type: Symbol
  
  # Link where this selector must do it's work. Example: http://test.com/view?id=
  field :link_template, type: String

  # Xpath for capybara, location for target data
  field :xpath, type: String

  # Css selector path, location for target data
  field :css, type: String
  
  # Need to be set if target data contains in attribute of selected tag instead of content. Can be empty.
  field :attr, type: Symbol
  
  # Need to be set if we need to move cursor to get target data. Can be empty.
  field :offset, type: Integer
  
  # Regular expression what will be executed on target data before saving. Can be empty.
  field :regexp, type: String

  # Format for parsed date
  field :date_format, type: String
  
  # Javascript code what must be executed on target page before accessing target data. Can be empty.
  field :js_code, type: String

  # Service field, used for sources with different setups of target data. Zakupki, for a example.
  field :group, type: Symbol

  # Service field, used as activity flag of selector 
  field :is_active, type: Boolean

  # Service field, used as parameter for grappling method, shows which mode must be used. Can be :single or :multiple
  field :grapple_mode, type: Symbol, default: :single

  scope :ids_set, where(:value_type => :ids_set)
  scope :data_fields, where(:value_type.ne => :ids_set)
  scope :active, where(:is_active => true)
end
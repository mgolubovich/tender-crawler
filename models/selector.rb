require './config/crawler_config'

class Selector
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :source

  # Type of field what this selector must extract. Example: title, start_price etc
  field :value_type, type: String
  
  # Link where this selector must do it's work. Example: http://test.com/view?id=
  field :link_template, type: String

  # Xpath for nokogiri, location for target data
  field :xpath, type: String
  
  # Need to be set if target data contains in attribute of selected tag instead of content. Can be empty.
  field :attr, type: String
  
  # Need to be set if we need to move cursor to get target data. Can be empty.
  field :offset, type: Integer
  
  # Regular expression what will be executed on target data before saving. Can be empty.
  field :regexp, type: String
  
  # Javascript code what must be executed on target page before accessing target data. Can be empty.
  field :js_code, type: String
end
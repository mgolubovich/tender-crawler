# Set of params for PaginationObserver
class PageManager
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :cartridge

  # Example:
  # action_type => :js
  # action_value => "$('.next-page').click();"

  field :action_type, type: Symbol
  field :action_value, type: String
  field :page_number_start_value, type: Integer, default: 1
  field :delay_between_pages, type: Integer, default: 0
  field :leading_zero, type: Boolean, default: false
end

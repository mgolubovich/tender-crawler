class PageManager
  include Mongoid::Document
  include Mongoid::Timestamps

  # Example:
  # action_type => :js
  # action_value => "$('.next-page').click();"
  
  field :action_type, type: Symbol
  field :action_value, type: String
end
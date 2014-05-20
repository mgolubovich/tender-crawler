class Cartridge
  include Mongoid::Document
  include Mongoid::Timestamps

  field :base_link_template, type: String
  field :base_list_template, type: String
  
  field :tender_type, type: String
end
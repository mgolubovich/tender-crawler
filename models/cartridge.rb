class Cartridge
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :source
  has_many :selectors
  has_many :page_managers

  field :name, type: String
  field :base_link_template, type: String
  field :base_list_template, type: String

  field :tender_type, type: String
end
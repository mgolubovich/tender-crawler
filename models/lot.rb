class Lot
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :tender

  field :name, type: String
  field :price, type: Float
end
class Region
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :cities
  field :name, type: String
  field :external_id, type: Integer
end
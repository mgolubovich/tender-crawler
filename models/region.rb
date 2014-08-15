class Region
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :cities
  field :name, type: String
  field :alt_name, type: String
  field :region_code, type: Integer

end
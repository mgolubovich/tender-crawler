class City
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :region

  field :name, type: String
  field :city_code, type: Integer
  field :region_code, type: Integer

end
class Postcode
  include Mongoid::Document
  include Mongoid::Timestamps

  field :postcode, type: String
  field :region_code, type: Integer
end
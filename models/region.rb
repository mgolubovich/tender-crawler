class Region
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :external_id, type: Integer
end
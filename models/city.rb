class City
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :region

  field :name, type: String
  field :external_id, type: Integer

end
class Contractor
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :protocols

  field :name, type: String
  field :inn, type: String
end

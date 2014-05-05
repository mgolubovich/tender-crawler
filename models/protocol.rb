require 'mongoid'

class Protocol
  
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :tender
  belongs_to :contractor

  # Temporal field
  field :data, type: String
end
require 'mongoid'

class Protocol
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :tender

  # Temporal field
  field :data, type: Hash
  
  def winner
    # method for determing winner by protocol
  end
end
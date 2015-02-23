# Protocol is structure which describes
# contenders and split them in winners
# and loosers.
class Protocol
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :tender

  # Temporal field
  field :inn, type: String

  index({ inn: 1 })

  # field for PHP post parser
  field :is_winner, type: Boolean

  field :tender_data, type: Hash

end

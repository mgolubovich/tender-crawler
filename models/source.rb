require 'mongoid'

class Source
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :tenders
  has_many :selectors
  # Source info
  field :name, type: String
  field :links, type: Hash

  # Service parametres
  field :tenders_update_frequency, type: Time
  field :is_active, type: Boolean

  # Example of proxy_update_frequency field value
  # This {"type":"hits","value":"100"} means what every 100 hits we must change proxy server
  # Another form - {"type":"time", "value":"5.minutes"} means what every 5 minutes we also must change proxy server
  field :proxy_update_frequency, type: Hash

  field :external_site_id, type: Integer

  scope :active, where(:is_active => true)

end
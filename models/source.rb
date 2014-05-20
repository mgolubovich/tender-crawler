class Source
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :tenders
  has_many :selectors

  # Source info
  field :name, type: String
  field :url, type: String

  # Service parametres
  field :tenders_update_frequency, type: Time
  field :is_active, type: Boolean
  field :last_imported_at, type: DateTime

  # Field used for invoking pre and post processing of data or parametres
  # Example: { :class_name => 'ZakupkiTrigger', :before => false, :after => true}
  field :trigger, type: Hash

  # Example of proxy_update_frequency field value
  # This {"type":"hits","value":"100"} means what every 100 hits we must change proxy server
  # Another form - {"type":"time", "value":"5.minutes"} means what every 5 minutes we also must change proxy server
  field :proxy_update_frequency, type: Hash

  field :external_site_id, type: Integer
  field :external_link_templates, type: Hash

  scope :active, where(:is_active => true)

end
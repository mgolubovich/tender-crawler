class Rule
  include Mongoid::Document
  include Mongoid::Timestamps

  has_one :selector

  field :regexp, type: String
  field :check_emptiness, type: Boolean
  field :check_length, type: Hash # Example { :more => 10, :less => 20 }
  field :failed_status, type: Symbol, default: :failed

  field :is_active, type: Boolean, default: true

  scope :active, where(:is_active => true)
end
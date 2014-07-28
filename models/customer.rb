class Customer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :short_name, type: String
  field :inn, type: String
  field :address, type: String
  field :mail_address, type: String
  field :email, type: String
  field :customer_name, type: String
  field :customer_telephone, type: String
  field :customer_fax, type: String
  field :source, type: String
end

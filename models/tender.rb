require 'mongoid'

class Tender
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :source
  
  # Timestamps, created_at and updated_at included via mongoid
  field :start_at, type: DateTime
  field :published_at, type: DateTime

  # Source info
  field :code_by_source, type: String
  field :source_link, type: String

  # Actual tender info
  field :title, type: String
  field :start_price, type: Float
  field :tender_form, type: String
  field :customer_name, type: String
  field :customer_adress, type: String
  field :customer_inn, type: String
  field :okdps, type: String
  field :documents, type: Hash

  # Fields for MySQL integration
  field :work_type, type: Integer
  field :external_city_id, type: Integer
  field :external_region_id, type: Integer
  field :external_db_id, type: Integer

  # Fields for syncronization based on md5(code_by_source + source_id). 
  # Used for determing of existing tender in mongo
  field :internal_code, type: String
end
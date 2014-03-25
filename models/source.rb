require './config/crawler_config'

class Source
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :link, type: String
  field :update_period, type: String
end
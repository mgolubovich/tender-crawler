# Document that desribes proxy-server
# used by ProxyManager
class Proxy
  include Mongoid::Document
  include Mongoid::Timestamps

  field :address, type: String
  field :port, type: String
  field :latency, type: Integer
end

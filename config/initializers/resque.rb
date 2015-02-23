require 'resque'
require 'resque/scheduler'

Dir.glob('./lib/jobs/*.rb').each { |file| require file }

uri = URI.parse('redis://localhost:6379/')

Resque.redis = Redis.new(
        host: uri.host,
        port: uri.port,
        password: uri.password)


Resque::Plugins::Timeout.timeout = 18600
Resque::Plugins::Timeout.switch = :on

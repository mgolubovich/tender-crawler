$:.unshift File.join(__FILE__, "../config")
$:.unshift File.join(__FILE__, "../models")

require 'sinatra/base'
require 'sinatra/twitter-bootstrap'
require 'bundler/setup'
require 'crawler_config'
require 'routes'

require 'source'
require 'tender'

class Crawler < Sinatra::Base
  register Sinatra::Twitter::Bootstrap::Assets

  set :app_file, __FILE__
  set :views, settings.root + '/views'
end
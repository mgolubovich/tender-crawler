$:.unshift File.join(__FILE__, "../config")

require 'sinatra/base'
require 'mongoid'
require 'bundler/setup'
require 'crawler_config'
require 'routes'

class Crawler < Sinatra::Base
  set :app_file, __FILE__
  set :views, settings.root + '/views'
end
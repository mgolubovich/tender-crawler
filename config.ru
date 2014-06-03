require 'sinatra/base'
require 'bundler'
require "rack-timeout"

Bundler.require

use Rack::Timeout

Dir.glob('./{models,lib,controllers}/*.rb').each { |file| require file }
Dir.glob('./config/initializers/*.rb').each { |file| require file}
Dir.glob('./lib/helpers/*.rb').each { |file| require file}
Dir.glob('./lib/triggers/*.rb').each { |file| require file}

map('/') { run FrontPageController }
map('/tenders') { run TendersController }
map('/moderation') { run TendersController }
map('/sources') { run SourcesController }
map('/controls') { run ManagementController }
map('/rules') { run RulesController }
map('/cartridges') { run CartridgesController }

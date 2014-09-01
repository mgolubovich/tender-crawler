require 'sinatra/base'
require 'bundler'
require 'rack-timeout'
require 'date'
require 'open-uri'
require 'resque/server'

Bundler.require

use Rack::Timeout

require './controllers/application_controller.rb'
Dir.glob('./{models,lib,controllers}/*.rb').sort.each { |file| require file }
Dir.glob('./lib/reaper/*.rb').each { |file| require file }
Dir.glob('./lib/managers/*.rb').each { |file| require file}
Dir.glob('./lib/processors/*.rb').each { |file| require file }
Dir.glob('./lib/exceptions/*.rb').each { |file| require file}
Dir.glob('./config/initializers/*.rb').each { |file| require file }
Dir.glob('./lib/helpers/*.rb').each { |file| require file }
Dir.glob('./lib/triggers/*.rb').each { |file| require file }

map('/') { run FrontPageController }
map('/tenders') { run TendersController }
map('/moderation') { run TendersController }
map('/sources') { run SourcesController }
map('/controls') { run ManagementController }
map('/rules') { run RulesController }
map('/cartridges') { run CartridgesController }
map('/api') { run ApiController }
map('/resque') { run Resque::Server.new }
map('/dev') { run DevController }

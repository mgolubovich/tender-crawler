require 'sinatra/base'
require 'bundler'

Bundler.require
Dir.glob('./{models,lib,controllers}/*.rb').each { |file| require file }
Dir.glob('./config/initializers/*.rb').each { |file| require file}
Dir.glob('./lib/helpers/*.rb').each { |file| require file}
Dir.glob('./lib/triggers/*.rb').each { |file| require file}

map('/') { run FrontPageController }
map('/tenders') { run TendersController }
map('/sources') { run SourcesController }
map('/controls') { run ManagementController }

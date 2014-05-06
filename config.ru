require 'sinatra/base'
require 'bundler'

Bundler.require
Dir.glob('./{models,lib,controllers,fatalities}/*.rb').each { |file| require file }
Dir.glob('./config/initializers/*.rb').each { |file| require file}

map('/') { run FrontPageController }
map('/tenders') { run TendersController }
map('/sources') { run SourcesController }
map('/controls') { run ManagementController }
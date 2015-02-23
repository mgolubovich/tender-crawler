require 'sinatra'
require 'bundler'
require 'date'
require 'open-uri'

Bundler.require

::Moped::BSON = ::BSON

Dir.glob('./config/initializers/*.rb').each { |file| require file }
Dir.glob('./models/**/*.rb').sort.each { |file| require file }
Dir.glob('./lib/helpers/*.rb').each { |file| require file }
Dir.glob('./lib/services/**/*.rb').sort.each { |file| require file }
Dir.glob('./lib/managers/*.rb').each { |file| require file }
Dir.glob('./lib/processors/*.rb').each { |file| require file }
Dir.glob('./lib/exceptions/*.rb').each { |file| require file }
Dir.glob('./lib/*.rb').each { |file| require file }
Dir.glob('./lib/reaper/*.rb').each { |file| require file }
Dir.glob('./tasks/*.rake').each { |r| load r }
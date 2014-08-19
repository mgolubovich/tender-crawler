require 'sinatra/base'
require 'bundler'
require 'date'
require 'open-uri'

Bundler.require
Dir.glob('./{models,lib,triggers}/*.rb').sort.each { |file| require file }
Dir.glob('./lib/reaper/*.rb').each { |file| require file}
Dir.glob('./lib/managers/*.rb').each { |file| require file}
Dir.glob('./lib/processors/*.rb').each { |file| require file}
Dir.glob('./config/initializers/*.rb').each { |file| require file}
Dir.glob('./lib/helpers/*.rb').each { |file| require file}
Dir.glob('./tasks/*.rake').each { |r| load r}
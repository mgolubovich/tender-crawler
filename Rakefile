require 'sinatra/base'
require 'bundler'

Bundler.require
Dir.glob('./{models,lib,controllers,triggers}/*.rb').sort.each { |file| require file }
Dir.glob('./lib/extra_parsing/*.rb').each { |file| require file}
Dir.glob('./lib/extra_parsing/*.rb').sort.each { |file| require file }
Dir.glob('./config/initializers/*.rb').each { |file| require file}
Dir.glob('./lib/helpers/*.rb').each { |file| require file}
Dir.glob('./tasks/*.rake').each { |r| load r}
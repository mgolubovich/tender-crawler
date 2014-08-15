# Base controller, not used directly
class ApplicationController < Sinatra::Base
  enable :sessions, :method_override
  set :views, File.expand_path('../../views', __FILE__)

  configure :development do
    Bundler.setup(:default, :development)
    set :environment, :development
    enable(
      :sessions,
      :logging,
      :static,
      :inline_templates,
      :method_override,
      :dump_errors, :run
    )
    Mongoid.load!(File.expand_path(File.join('config', 'mongoid.yml')))
  end

  configure :test do
    Bundler.setup(:default, :test)
    set :environment, :test
    enable(
      :sessions,
      :static,
      :inline_templates,
      :method_override,
      :raise_errors
    )
    disable :run, :dump_errors, :logging
    Mongoid.load!(File.expand_path(File.join('config', 'mongoid.yml')))
  end

  configure :production do
    Bundler.setup(:default, :production)
    set :environment, :production
    enable(
      :sessions,
      :logging,
      :static,
      :inline_templates,
      :method_override,
      :dump_errors,
      :run
    )
    Mongoid.load!(File.expand_path(File.join('config', 'mongoid.yml')))
  end

  helpers WillPaginate::Sinatra::Helpers

  helpers do
    def paginate(collection)
      options = {
        renderer: BootstrapPagination::Sinatra,
        inner_window: 0,
        outer_window: 0,
        previous_label: '&laquo;',
        next_label: '&raquo;'
      }
      will_paginate collection, options
    end
  end

  use Rack::Auth::Basic, 'Restricted Area' do |username, password|
    username == 'parser' && password == 'laserdisk'
  end
end

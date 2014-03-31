class SourcesController < ApplicationController

  get '/overview' do
    haml :sources
  end

end
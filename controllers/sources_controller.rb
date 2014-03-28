class SourcesController < ApplicationController

  get '/overview' do
    haml :index
  end

end
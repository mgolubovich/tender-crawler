class SourcesController < ApplicationController

  get '/overview' do
    @sources = Source.order_by(created_at: :asc)
    haml :sources
  end

end
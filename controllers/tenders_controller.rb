class TendersController < ApplicationController

  get '/overview' do
    haml :tenders
  end

end
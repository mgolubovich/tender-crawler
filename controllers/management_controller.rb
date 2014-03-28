class ManagementController < ApplicationController
  get '/controls' do
    haml :controls
  end
end
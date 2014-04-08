class TendersController < ApplicationController

  get '/overview' do
    @tenders = Tender.order_by(created_at: :desc)
    haml :tenders
  end

end
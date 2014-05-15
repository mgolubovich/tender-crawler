class TendersController < ApplicationController

  get '/' do
    @tenders = Tender.order_by(created_at: :desc)
    haml :tenders
  end

  get '/overview' do
    @tenders = Tender.order_by(created_at: :desc)
    haml :tenders
  end

  get '/new' do
    haml :'tenders/new'
  end

  get '/show/:id' do
    @tenders = Tender.find params[:id]
    haml :'tenders/show'
  end

end

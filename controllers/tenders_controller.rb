class TendersController < ApplicationController

  get '/' do
    @tenders = Tender.order_by(created_at: :desc).paginate(page: params[:page], per_page: 25)
    @tenders_count = Tender.count
    haml :tenders
  end

  get '/overview' do
    redirect '/tenders'
  end

  get '/:source_id' do
    if Source.where(_id: params[:source_id]).exists?
      @tenders = Tender.where(:source_id => params[:source_id]).order_by(created_at: :desc).paginate(page: params[:page], per_page: 25)
      @source = Source.find params[:source_id]
      @tenders_count = Tender.where(:source_id => @source._id).count
      haml :tenders
    else
      redirect ('/tenders')
    end
  end

  get '/new' do
    haml :'tenders/new'
  end

  get '/show/:id' do
    @tenders = Tender.find params[:id]
    haml :'tenders/show'
  end

  get '/:tender_id/destroy' do
    tender = Tender.find params[:tender_id]
    tender.destroy
    redirect '/tenders'
  end
end

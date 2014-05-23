class TendersController < ApplicationController

  get '/' do
    @tenders = Tender.order_by(created_at: :desc)
    @tender_counter = params[:page].nil? ? 1 : params[:page].to_i * 25 - 25
    @tenders = @tenders.where(source_id: params[:source_id]) if params[:source_id]
    @source = Source.find(params[:source_id]) if params[:source_id]

    unless params[:start_date].nil? && params[:end_date].nil?
      @start_date = params[:start_date]
      @end_date = params[:end_date]
      @start_date_db = Time.parse(@start_date)
      @end_date_db = Time.parse(@end_date) + 23.hours + 59.minutes + 59.seconds
      @tenders = @tenders.where(created_at: @start_date_db..@end_date_db)
    end
    @tenders_count = @tenders.count
    @tenders = @tenders.paginate(page: params[:page], per_page: 25)
    haml :tenders
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

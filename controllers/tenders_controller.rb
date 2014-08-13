class TendersController < ApplicationController

  get '/' do

    @filter = params[:filter]
    @filter = {} if @filter.nil?
    @filter[:created_by] = '' if @filter[:created_by].nil?

    @tender_counter = params[:page].nil? ? 1 : params[:page].to_i * 25 - 25

    @tenders = Tender.order_by(created_at: :desc)
    @tenders = @tenders.where(source_id: params[:source_id]) if params[:source_id]
    @source = Source.find(params[:source_id]) if params[:source_id]

    unless @filter[:start_date].to_s.empty?
      @tenders = @tenders.where(:created_at.gte => Time.parse(@filter[:start_date]).at_beginning_of_day)
    end

    unless @filter[:end_date].to_s.empty?
      @tenders = @tenders.where(:created_at.lte => Time.parse(@filter[:end_date]).end_of_day)
    end

    @tenders = @tenders.where(code_by_source: @filter[:search]) unless @filter[:search].to_s.empty?
    @tenders = @tenders.where(created_by: @filter[:created_by].to_sym) unless @filter[:created_by].to_s.empty?

    @tenders_count = Statistics.first.global_tenders_count
    @tenders = @tenders.paginate(page: params[:page], per_page: 25)

    haml :tenders
  end

  get '/new' do
    haml :'tenders/new'
  end

  post '/new' do
    tender = Tender.create(parse_tender_form)
    redirect "tenders/edit/#{tender._id}"
  end

  get '/check' do
    content_type :json
    @tender = Tender.where(:source_id => params[:source_id]).where(:code_by_source => params[:code_by_source])
    @tender.count > 0 ? { :result => @tender.first._id}.to_json : {:result => '0'}.to_json
  end

  get '/edit/:id' do
    @tender = Tender.find params[:id]
    @source = @tender.source_id
    haml :'tenders/edit'
  end

  post '/edit/:id' do
    tender = Tender.find params[:id]
    tender.update_attributes!(parse_tender_form)
    tender.save
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

  get '/push' do
    if Tender.where(external_work_type: -1).count == 0
      "Nothing to do!"
    else
      @tender = params[:last] ? Tender.order_by(moderated_at: :asc).last : Tender.where(external_work_type: -1).order_by(created_at: :desk).last
      @moderated_today_count = Statistics.last.moderation_today_count
      haml :moderation
    end
  end

  get '/:t_id/:ext_w_type' do
    t = Tender.find params[:t_id]
    t.external_work_type = params[:ext_w_type].to_i
    t.moderated_at = Time.now
    t.save
    redirect "/moderation/push"
  end
private
  def parse_tender_form
    data = Hash.new
    data = {:source_id => params[:source], :code_by_source => params[:code_by_source], :title => params[:title], :tender_form => params[:tender_form], :external_work_type => params[:external_work_type].to_i, :customer_inn => params[:customer_inn], :customer_name => params[:customer_name], :customer_address => params[:customer_address], :id_by_source => params[:id_by_source], :group => params[:group].to_sym}
    data[:start_at] = Time.parse(params[:start_at]) if params[:start_at]
    data[:published_at] = Time.parse(params[:published_at]) if params[:published_at]
    data[:created_by] = :human
    #"doc_title"=>"doc_title", "doc_link"=>"doc_link"} #допилю
    data
  end
end

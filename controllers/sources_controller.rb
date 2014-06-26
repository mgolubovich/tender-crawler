class SourcesController < ApplicationController

  get '/' do
    @sources = Source.order_by(created_at: :asc)
    @sources = @sources.where(name: Regexp.new(params[:search], Regexp::IGNORECASE)) if params[:search]
    @sources = @sources.paginate(page: params[:page], per_page: 25)
    @source_counter = params[:page].nil? ? 0 : params[:page].to_i * 25 - 25
    haml :sources
  end

  get '/overview' do
    redirect '/sources'
  end

  get '/new' do
    haml :'sources/new'
  end

  post '/new' do
    source = Source.new
    attributes = parse_source_form
    source.update_attributes!(attributes)
    source.save
    redirect "/sources/edit/#{source._id}"
  end

  get '/edit/:id' do
    @sources = Source.find params[:id]
    @cartridges = @sources.cartridges
  #  @selectors = @sources.selectors
    haml :'sources/edit'
  end

  post '/edit' do
    source = Source.find params[:source_id]
    attributes = parse_source_form
    source.update_attributes!(attributes)
    source.save
    redirect "/sources"
  end

  get '/destroy/:id' do
    source = Source.find params[:id]
    source.destroy
    redirect "/sources"
  end

private
  def parse_source_form
    data = {}
    data = {:name => params[:source_name], :url => params[:source_url], :external_site_id => params[:source_external_site_id], :comment => params[:source_comment]}
    data[:is_active] = params[:source_activity] == 'active' ? true : false
    data
  end
end

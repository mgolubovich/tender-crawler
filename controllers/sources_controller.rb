class SourcesController < ApplicationController

  get '/' do
    @sources = Source.order_by(created_at: :asc).paginate(page: params[:page], per_page: 25)
    @source_counter = params[:page].nil? ? 1 : params[:page].to_i * 25 - 25
#    @source_counter = @source_counter * 25 - 25 + 1
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
    source.name = params[:source_name]
    source.url = params[:source_url]
    source.is_active = params[:source_activity] == 'active' ? true : false
    source.external_site_id = params[:source_external_site_id]
    source.comment = params[:source_comment]
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
    source.name = params[:source_name]
    source.url = params[:source_url]
    source.is_active = params[:source_activity] == 'active' ? true : false
    source.external_site_id = params[:source_external_site_id]
    source.comment = params[:source_comment]
    source.save
    redirect "/sources"
  end

  get '/destroy/:id' do
    source = Source.find params[:id]
    source.destroy
    redirect "/sources"
  end
end

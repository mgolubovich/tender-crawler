class SourcesController < ApplicationController


  get '/overview' do
    @sources = Source.order_by(created_at: :asc)
    haml :sources
  end

  get '/new' do
    haml :'sources/new'
  end

  post '/new' do
    source = Source.new
    source.name = params[:source_name]
    source.is_active = params[:source_activity] == 'active' ? true : false
    source.external_site_id = params[:source_external_site_id]
    source.save
    redirect '/sources/overview'
  end

  get '/edit/:id' do
    @sources = Source.find params[:id]
    haml :'sources/edit'
  end

  post '/edit' do
    source = Source.find params[:source_id]
    source.name = params[:source_name]
    source.is_active = params[:source_activity] == 'active' ? true : false
    source.external_site_id = params[:source_external_site_id]
    source.save
    redirect '/sources/overview'
  end

  get '/destroy/:id' do
    source = Source.find params[:id]
    source.destroy
    redirect '/sources/overview'
  end

end

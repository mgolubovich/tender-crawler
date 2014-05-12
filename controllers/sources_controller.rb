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
    @selectors = @sources.selectors
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

  get '/edit/:source_id/add_s' do
    @source_id = params[:source_id]
    haml :'selectors/new'
  end

  post '/edit/:source_id/add_s' do
   selector = Source.find(params[:source_id]).selectors.new
 #  selector.source_id = params[:selector_source_id]
   selector.value_type = params[:selector_value]
   selector.link_template = params[:selector_link]
   selector.xpath = params[:selector_xpath]
   selector.css = params[:selector_css]
   selector.attr = params[:selector_attr]
   selector.offset = params[:selector_offset]
   selector.regexp = params[:selector_regexp]
   selector.date_format = params[:selector_date_format]
   selector.js_code = params[:selector_js_code]
   selector.is_active = params[:selector_activity] == 'active' ? true : false
   selector.save
   redirect "/sources/edit/#{selector.source_id}"
 end

  get '/destroy/:id' do
    source = Source.find params[:id]
    source.destroy
    redirect '/sources/overview'
  end

end

class SourcesController < ApplicationController

  get '/' do
    @sources = Source.order_by(created_at: :asc).paginate(page: params[:page], per_page: 25)
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
    source.is_active = params[:source_activity] == 'active' ? true : false
    source.external_site_id = params[:source_external_site_id]
    source.save
    redirect "/sources/edit/#{source._id}"
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
    redirect '/sources'
  end

  get '/edit/:source_id/add_s' do
    @source_id = params[:source_id]
    haml :'selectors/new'
  end

 post '/edit/:source_id/add_s' do
   selector = Source.find(params[:source_id]).selectors.new
 #  selector.source_id = params[:selector_source_id]
   selector.value_type = params[:selector_value].to_sym
   selector.link_template = params[:selector_link]
   selector.xpath = params[:selector_xpath]
   selector.css = params[:selector_css]
   selector.attr = params[:selector_attr]
   selector.offset = params[:selector_offset].to_i
   selector.regexp = {"mode" => params[:selector_mode_reg], "pattern" => params[:selector_pat_reg]}
  # selector.regexp[:mode] = params[:selector_mode_reg]
  # selector.regexp[:pattern] = params[:selector_pat_reg]
   selector.date_format = params[:selector_date_format]
   selector.js_code = params[:selector_js_code]
   selector.group = params[:selector_group].to_sym
   selector.is_active = params[:selector_activity] == 'active' ? true : false
   selector.save
   redirect "/sources/edit/#{selector.source_id}"
 end

 get '/edit/:source_id/selector/:id' do
   @source_id = params[:source_id]
   @selector_id = params[:id]
   @selector = Selector.find params[:id]
   @rule = @selector.rules
   haml :'selectors/edit'
 end

 post '/edit/:source_id/selector/:id' do
   selector = Selector.find params[:selector_id]
   selector.value_type = params[:selector_value].to_sym
   selector.link_template = params[:selector_link]
   selector.xpath = params[:selector_xpath]
   selector.css = params[:selector_css]
   selector.attr = params[:selector_attr]
   selector.offset = params[:selector_offset].to_i
   selector.regexp["mode"] = params[:selector_mode_reg] == 'gsub' ? 'gsub' : 'match'
   selector.regexp["pattern"] = params[:selector_pat_reg]
   selector.date_format = params[:selector_date_format]
   selector.js_code = params[:selector_js_code]
   selector.group = params[:selector_group].to_sym
   selector.is_active = params[:selector_activity] == 'active' ? true : false
   selector.save
   redirect "/sources/edit/#{selector.source_id}"
 end


  get '/destroy/:id' do
    source = Source.find params[:id]
    source.destroy
    redirect "/sources"
  end

  get '/edit/:source_id/selector/:id/destroy' do
    source_id = params[:source_id]
    selector = Selector.find params[:id]
    selector.destroy
    redirect "/sources/edit/#{source_id}"
  end

end

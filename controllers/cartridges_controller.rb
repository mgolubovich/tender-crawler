class CartridgesController < ApplicationController
  get '/' do
    @cartridges = Cartridge.order_by(created_at: :desc)
    @cartridges = @cartridges.where(source_id: params[:source_id]) if params[:source_id] #cartridges in some source
    @source_id = params[:source_id] if params[:source_id]
    @cartridges = @cartridges.paginate(page: params[:page], per_page: 25) #paginate
    haml :cartridges
  end

  get '/new' do
    @sources = Source.order_by(created_at: :asc)
    @source_id = params[:source_id]
    haml :'cartridges/new'
  end

  post '/new' do
    cartridge = Source.find(params[:cartridge_source]).cartridges.new
    cartridge.name = params[:cartridge_name]
    cartridge.base_link_template = params[:cartridge_base_link]
    cartridge.base_list_template = params[:cartridge_base_list]
    cartridge.tender_type = params[:cartridge_tender_type]
    cartridge.is_active = params[:cartridge_activity] == 'active' ? true : false
    cartridge.save
    pm = cartridge.page_managers.new
    pm.action_type = params[:pm_type].to_sym
    pm.action_value = params[:pm_value]
    pm.save
    redirect "/cartridges/edit/#{cartridge._id}"
  end

  get '/edit/:cart_id' do
    @cartridge = Cartridge.find params[:cart_id]
    @pm = @cartridge.page_managers.last
    @selectors = @cartridge.selectors
    @sources = Source.order_by(created_at: :asc)
    haml :'cartridges/edit'
  end

  post '/edit' do
    cartridge = Cartridge.find params[:cartridge_id]
    cartridge.name = params[:cartridge_name]
    cartridge.source_id = params[:cartridge_source]
    cartridge.base_link_template = params[:cartridge_base_link]
    cartridge.base_list_template = params[:cartridge_base_list]
    cartridge.tender_type = params[:cartridge_tender_type]
    cartridge.is_active = params[:cartridge_activity] == 'active' ? true : false
    cartridge.save
    pm = PageManager.find params[:pm_id]
    pm.action_type = params[:pm_type].to_sym
    pm.action_value = params[:pm_value]
    pm.save
    redirect "/cartridges"
  end

  get '/destroy/:id' do
    cartridge = Cartridge.find params[:id]
    cartridge.destroy
    redirect "/cartridges"
  end

  get '/edit/:cart_id/add_s' do
    @cartridge_id = params[:cart_id]
    haml :'selectors/new'
  end

 post '/edit/:cart_id/add_s' do
   selector = Cartridge.find(params[:cart_id]).selectors.new
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
  # selector.group = params[:selector_group].to_sym
   selector.is_active = params[:selector_activity] == 'active' ? true : false
   selector.to_type = params[:selector_to_type]
   selector.save
   redirect "/cartridges/edit/#{selector.cartridge_id}"
 end

 get '/edit/:cart_id/selector/:id' do
   @cartridge_id = params[:cart_id]
   @selector_id = params[:id]
   @selector = Selector.find params[:id]
   @rule = @selector.rules
   haml :'selectors/edit'
 end

 post '/edit/:cart_id/selector/:id' do
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
  # selector.group = params[:selector_group].to_sym
   selector.to_type = params[:selector_to_type]
   selector.is_active = params[:selector_activity] == 'active' ? true : false
   selector.save
   redirect "/cartridges/edit/#{selector.cartridge_id}"
 end

 get '/edit/:cart_id/selector/:id/destroy' do
   cartridge_id = params[:cart_id]
   selector = Selector.find params[:id]
   selector.destroy
   redirect "/cartridges/edit/#{cartridge_id}"
 end

end

class CartridgesController < ApplicationController
  require 'debugger'
  get '/' do
    @cartridges = Cartridge.order_by(created_at: :desc)
    @cartridges = @cartridges.where(source_id: params[:source_id]) if params[:source_id] #cartridges in some source
    @source_id = params[:source_id] if params[:source_id]
    @cartridges = @cartridges.paginate(page: params[:page], per_page: 25) #paginate
    @sources = Source.order_by(created_at: :asc)
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
    @value_types = YAML.load_file('config/value_types.yml')
    @value_types = @value_types.map {|v| v.to_sym}
    @used_keys = @selectors.distinct(:value_type)

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
    @source = Cartridge.find(@cartridge_id).source
    @link_template = Cartridge.find(@cartridge_id).base_link_template
    @value_types = YAML.load_file('config/value_types.yml')
    haml :'selectors/new'
  end

  get '/edit/:cart_id/add_s/:value_type' do
    @cartridge_id = params[:cart_id]
    @source = Cartridge.find(@cartridge_id).source
    @link_template = Cartridge.find(@cartridge_id).base_link_template
    @value_types = YAML.load_file('config/value_types.yml')
    @value_type = params[:value_type]


    haml :'selectors/new'
  end

  post '/edit/:cart_id/add_s' do
   cartridge = Cartridge.find params[:cart_id]
   selector = cartridge.selectors.new
   selector.source_id = cartridge.source_id #Source_id fix
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
   selector.priority = params[:selector_priority].to_i
  # selector.group = params[:selector_group].to_sym
   selector.is_active = params[:selector_activity] == 'active' ? true : false
   selector.to_type = params[:selector_to_type]
  #  params[:selector_value].length > 0 ?
   selector.save
   redirect "/cartridges/edit/#{selector.cartridge_id}"
  end

  get '/edit/:cart_id/selector/:id' do
   @cartridge_id = params[:cart_id]
   @selector_id = params[:id]
   @selector = Selector.find params[:id]
   @rule = @selector.rules
   @source = @selector.source
   @value_types = YAML.load_file('config/value_types.yml')
   haml :'selectors/edit'
  end

  get '/edit/:cart_id/selector/:id/check' do
    content_type :json

    entity_id = params[:entity_id].length > 0 ? params[:entity_id] : @selector.source.tenders.last.id_by_source
    %x(DISPLAY=localhost:1.0 xvfb-run rake parsing:test_grapple[#{params[:id]},#{entity_id}])
  end

  post '/edit/:cart_id/selector/:id' do
    selector = Selector.find params[:selector_id]
    selector.value_type = params[:selector_value].to_sym
    selector.link_template = params[:selector_link]
    selector.xpath = params[:selector_xpath]
    selector.css = params[:selector_css]
    selector.attr = params[:selector_attr]
    
    selector.offset = {"start" => params[:selector_offset_start].to_i, "end" => params[:selector_offset_end].to_i}
    selector.offset["end"] = -1 if selector.offset["start"] != 0 && selector.offset["end"] == 0

    selector.regexp["mode"] = params[:selector_mode_reg] == 'gsub' ? 'gsub' : 'match'
    selector.regexp["pattern"] = params[:selector_pat_reg]
    selector.date_format = params[:selector_date_format]
    selector.js_code = params[:selector_js_code]
    # selector.group = params[:selector_group].to_sym
    selector.priority = params[:selector_priority].to_i
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

  get '/check/:cartridge_id' do
   # @cartridge = Cartridge.find params[:cartridge_id]
   # @check_tender = Reaper.new(cartridge.source_id, 1, cartridge._id).reap
    @check_tender = Tender.find '53749ae21d0aab0c75000001'
    @cartridge = Cartridge.where(source_id: @check_tender.source_id, tender_type: @check_tender.group).first

    @fields_list = YAML.load_file('config/selectors_assoc.yml')
    @value_types = YAML.load_file('config/value_types.yml')
    @value_types.delete("ids_set")
    @selectors_data = Hash.new
    @value_types.each do |value_type|
      is_exist = @cartridge.selectors.where(:value_type => value_type).count > 0 ? true : false
      selector = is_exist ? @cartridge.selectors.active.where(:value_type => value_type).first : nil
      @selectors_data[value_type.to_sym] = { :is_exist => is_exist, :id => (selector.nil? ? nil : selector._id)}
    end
    #debugger
    haml :'check'
  end

  post '/copy' do
    @cartridge = Cartridge.find params[:cartridge_id]
    # Copy cart
    dest_cart = Cartridge.new
    dest_cart.update_attributes!(@cartridge.attributes)
    dest_cart.name = params[:cartridge_name]
    dest_cart.source_id = params[:source]
    dest_cart.base_link_template = "$entity_id"
    dest_cart.base_list_template = "$page_number"
    dest_cart.save

    # PageManagers
    dest_pm = dest_cart.page_managers.new
    if params[:copy_pm]
     dest_pm.update_attributes!(@cartridge.page_managers.last.attributes)
     dest_pm.cartridge_id = dest_cart._id
    end
    dest_pm.save

    # Selectors
    if params[:copy_selectors]
     @cartridge.selectors.each do |s|
       dest_s = Selector.new
       dest_s.update_attributes!(s.attributes)
       dest_s.cartridge_id = dest_cart._id
       dest_s.source_id = dest_cart.source_id
       dest_s.link_template = ""
       dest_s.save
       if params[:copy_rules]
         dest_r = s.rules.new
         dest_r.update_attributes!(s.rules.last.attributes)
         dest_r.selector_id = dest_s._id
         dest_r.save
       end
     end
    end

    # temp redirect
    redirect "/cartridges/edit/#{dest_cart._id}"
  end
end


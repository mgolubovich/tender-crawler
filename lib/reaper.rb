require 'debugger'
require 'capybara/dsl'
require 'capybara/webkit'

class Reaper
  
  include Capybara::DSL
  Capybara.default_driver = :webkit
  Capybara.run_server = false

  def initialize(source, limit=0)
    @source = source
    @limit = limit
    @fields_status = Hash.new

    @current_page = 0

    log_started_parsing(@source.name)
  end

  def get_cartridges
    @cartridges = @source.cartridges.active
  end

  def apply_rules(value, selector)
    @fields_status[selector.value_type.to_sym] = Arbiter.new(value, selector.rule.first).judge if selector.rules.count > 0
  end

  def next_page(cartridge)
    page_manager = cartridge.page_managers.first
    if page_manager.action_type == :get
      @current_page += 1
      visit cartridge.base_list_template.gsub('$page_number', @current_page.to_s)
    end
  end

  def get_ids(cartridge)
    Grappler.new(cartridge.selectors.active.ids_set.first).grapple_all.uniq
  end

  def reap
    get_cartridges
    @cartridges.each do |cartridge|
      @current_page = 0
      #visit(cartridge.base_list_template) unless current_url == cartridge.base_list_template

      ids_set = []
      
      while @limit > ids_set.count
        next_page(cartridge) if ids_set.count < @limit
        ids_set += get_ids(cartridge)
      end
      #debugger
      log_got_ids_set(ids_set.count)

      ids_set.each do |entity_id|
        tender_status = Hash.new
        # HACK Fix later
        entity_id = entity_id.first if entity_id.is_a?(Array)
        #

        code = Grappler.new(cartridge.selectors.active.where(:value_type => :code_by_source).first, entity_id).grapple
        log_got_code(code)

        tender = @source.tenders.find_or_create_by(code_by_source: code)

        cartridge.selectors.data_fields.each do |selector|
          log_start_grappling(selector.value_type)
          value = Grappler.new(selector, entity_id).grapple 
          
          tender[selector.value_type.to_sym] = value
          apply_rules(value, selector)
          
          log_got_value(selector.value_type, value)
        end

        tender.id_by_source = entity_id
        tender.source_link = cartridge.base_link_template.gsub('$entity_id', entity_id)
        tender.group = cartridge.tender_type
        
        @fields_status.each_pair do |field, status|
          tender_status[:state] = status
          tender_status[:failed_fields] = [] unless tender_status[:failed_fields].kind_of(Array)
          tender_status[:failed_fields] << field if status == :failed

          tender_status[:fields_for_moderation] = [] unless tender_status[:fields_for_moderation].kind_of(Array)
          tender_status[:fields_for_moderation] << field if status == :moderation
        end

        tender.status = tender_status
        
        tender.save
        log_tender_saved(tender[:_id])

      end
    end
  end

end
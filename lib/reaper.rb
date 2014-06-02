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

    load_work_type_codes
    
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

  def get_docs(cartridge, entity_id)
    documents = []
    doc_title_sl = cartridge.selectors.where(:value_type => :doc_title).first
    doc_link_sl = cartridge.selectors.where(:value_type => :doc_link).first
    doc_titles = []
    doc_links = []

    doc_titles = Grappler.new(doc_title_sl,entity_id.to_s).grapple_all
    doc_links = Grappler.new(doc_link_sl, entity_id.to_s).grapple_all

    i = 0;
    doc_titles.each do |title|
      documents << { doc_title: title, doc_link: doc_links[i] }
      i += 1
    end

    documents
  end

  def get_work_type(cartridge, entity_id)
    work_types = []
    work_type_codes = []
    work_type_titles = []

    work_type_codes << Grappler.new(cartridge.selectors.where(:value_type => :work_type_code).first, entity_id.to_s).grapple
    work_type_titles << Grappler.new(cartridge.selectors.where(:value_type => :work_type_title).first, entity_id.to_s).grapple

    i = 0
    work_type_codes.each do |code|
      work_types << { "code" =>  code, "title" => work_type_titles[i]}
      i += 1
    end

    work_types
  end

  def load_work_type_codes
    @construct_keys = [] # 1
    @project_keys = [] # 2
    @research_keys = [] # 3
    @supply_keys = [] # 4
    @service_keys = [] # 5

    @construct_keys = YAML.load_file('config/work_type_codes/construct.yml').keys + YAML.load_file('config/work_type_codes/construct_okpd.yml').keys
    @project_keys = YAML.load_file('config/work_type_codes/project.yml').keys + YAML.load_file('config/work_type_codes/project_okpd.yml').keys
    #@research_keys = YAML.load_file('config/work_type_codes/research.yml').keys
    @supply_keys = YAML.load_file('config/work_type_codes/supply.yml').keys + YAML.load_file('config/work_type_codes/supply_okpd.yml').keys
    @service_keys = YAML.load_file('config/work_type_codes/service_okdp.yml').keys
  end

  def set_external_work_type_code(work_type)
    external_work_type = 0

    work_type.each do |w|
      external_work_type = 1 if @construct_keys.include? w["code"]
      external_work_type = 2 if @project_keys.include? w["code"]
      #external_work_type = 3 if @research_keys.include? w["code"]
      external_work_type = 4 if @supply_keys.include? w["code"]
      external_work_type = 5 if @service_keys.include? w["code"]

      unless w["code"].include?('.')
        external_work_type = 1 if w["code"].start_with?('451') || w["code"].start_with?('452') || w["code"].start_with?('453') || w["code"].start_with?('454')
        external_work_type = 2 if w["code"].start_with?('456')
        external_work_type = 4 if w["code"].start_with?('455') || w["code"].start_with?('459')
      else
        external_work_type = 1 if w["code"].start_with?('45')
        external_work_type = 2 if w["code"].start_with?('74.2')
      end
    end
    external_work_type
  end

  def reap(ids_set = [])
    get_cartridges
    @cartridges.each do |cartridge|
      @current_page = 0
      #visit(cartridge.base_list_template) unless current_url == cartridge.base_list_template
      
      unless ids_set.count > 0
        while @limit > ids_set.count
          next_page(cartridge) if ids_set.count < @limit
          ids_set += get_ids(cartridge)
        end
      end
      #ids_set = get_ids(cartridge) unless ids_set.count > 0
      
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
        tender.documents = get_docs(cartridge, entity_id)
        tender.work_type = get_work_type(cartridge, entity_id)
        tender.external_work_type = set_external_work_type_code(tender.work_type)
        #debugger
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

  private

  def set_region_id
    
  end

end
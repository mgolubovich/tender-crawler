require 'debugger'
require 'capybara/dsl'
require 'capybara/webkit'

class Reaper
  attr_reader :result

  def initialize(source, args = {}) # { :limit => 0, :cartridge_id => nil, :is_checking => false }
    @reaper_params = ReaperParams.new(source, args)
    @current_tender = {}
    load_work_type_codes    
    log_started_parsing(@reaper_params.source.name)
  end

  def reap
    get_cartridges
    # debugger
    @cartridges.each do |cartridge|
      @reaper_params[:reaped_tenders_count] = 0
      ids_set = []
      pagination = PaginationObserver.new(cartridge.page_managers.first)

      unless ids_set.count > 0
        while @reaper_params.args[:limit] > ids_set.count
          # debugger
          pagination.next_page if ids_set.count < @reaper_params.args[:limit]
          ids_set += get_ids(cartridge)
        end
      end
      
      log_got_ids_set(ids_set.count)

      ids_set.each do |entity_id|
        break if @reaper_params.status[:reaped_tenders_count] >= @reaper_params.args[:limit]
        tender_status = Hash.new
        # HACK Fix later
        entity_id = entity_id.first if entity_id.is_a?(Array)
        #

        code = Grappler.new(cartridge.selectors.active.where(:value_type => :code_by_source).first, entity_id).grapple
        log_got_code(code)

        tender = @reaper_params.source.tenders.find_or_create_by(code_by_source: code)

        cartridge.selectors.data_fields.order_by(priority: :desc).each do |selector|
          log_start_grappling(selector.value_type)
          value = Grappler.new(selector, entity_id).grapple 
          
          tender[selector.value_type.to_sym] = value
          apply_rules(value, selector)
          
          log_got_value(selector.value_type, value)
        end

        tender.id_by_source = entity_id
        tender.source_link = cartridge.base_link_template.gsub('$entity_id', entity_id)
        tender.group = cartridge.tender_type
        tender.documents = get_docs(cartridge, entity_id) if cartridge.selectors.where(value_type: :doc_title).count > 0
        tender.work_type = get_work_type(cartridge, entity_id) if cartridge.selectors.where(value_type: :work_type_code).count > 0
        tender.external_work_type = set_external_work_type_code(tender.work_type) unless tender.work_type.nil?
        tender.external_work_type = -1 if tender.work_type.nil?
        tender.external_db_id = Tender.max(:external_db_id).to_i + 1 if tender.external_db_id.nil?
        
        @reaper_params.status[:fields_status].each_pair do |field, status|
          tender_status[:state] = status
          tender_status[:failed_fields] = [] unless tender_status[:failed_fields].kind_of(Array)
          tender_status[:failed_fields] << field if status == :failed

          tender_status[:fields_for_moderation] = [] unless tender_status[:fields_for_moderation].kind_of(Array)
          tender_status[:fields_for_moderation] << field if status == :moderation
        end

        tender.status = tender_status
        tender.save unless @reaper_params.args[:is_checking]
        @reaper_params.status[:result] << tender

        @reaper_params.status[:reaped_tenders_count] += 1

        log_tender_saved(tender[:_id])

      end
      ids_set = []
    end
    @reaper_params.status[:result].first
  end

  private

  def get_cartridges
    @cartridges = @reaper_params.source.cartridges.active
    @cartridges = @reaper_params.source.cartridges.where(_id: @cartridge_id) if @reaper_params.args[:cartridge_id]
  end

  def apply_rules(value, selector)
    @reaper_params.status[:fields_status][selector.value_type.to_sym] = Arbiter.new(value, selector.rule.first).judge if selector.rules.count > 0
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
      unless code.nil?
        work_types << { "code" =>  code.to_s, "title" => work_type_titles[i].to_s}
        i += 1
      end
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
    # @research_keys = YAML.load_file('config/work_type_codes/research.yml').keys
    @supply_keys = YAML.load_file('config/work_type_codes/supply.yml').keys + YAML.load_file('config/work_type_codes/supply_okpd.yml').keys
    @service_keys = YAML.load_file('config/work_type_codes/service_okdp.yml').keys
  end

  def set_external_work_type_code(work_type)
    external_work_type = 0
    
    if work_type.count > 0
      work_type.each do |w|
        external_work_type = 1 if @construct_keys.include? w["code"] && !w["code"].blank?
        external_work_type = 2 if @project_keys.include? w["code"] && !w["code"].blank?
        # external_work_type = 3 if @research_keys.include? w["code"] && !w["code"].blank?
        external_work_type = 4 if @supply_keys.include? w["code"] && !w["code"].blank?
        external_work_type = 5 if @service_keys.include? w["code"] && !w["code"].blank?

        unless w["code"].include?('.') && w["code"].blank?
          external_work_type = 1 if w["code"].start_with?('451') || w["code"].start_with?('452') || w["code"].start_with?('453') || w["code"].start_with?('454')
          external_work_type = 2 if w["code"].start_with?('456')
          external_work_type = 4 if w["code"].start_with?('455') || w["code"].start_with?('459')
        else
          external_work_type = 1 if w["code"].start_with?('45')
          external_work_type = 2 if w["code"].start_with?('74.2')
        end
      end
    else
      external_work_type = -1
    end

    external_work_type
  end

  class ReaperParams
    attr_accessor :source, :args, :status

    def initialize(source, args)
      @source = source
      @args = args
      @status = {}

      @args[:limit] = 500 unless @args.has_key? :limit
      @args[:cartridge_id] = nil unless @args.has_key? :cartridge_id
      @args[:is_checking] = false unless @args.has_key? :is_checking

      @status[:result] = []
      @status[:reaped_tenders_count] = 0
      @status[:fields_status] = Hash.new
    end
  end

  class PaginationObserver
    attr_accessor :current_page, :initial_visit, :page_manager
    
    include Capybara::DSL
    Capybara.default_driver = :webkit
    Capybara.run_server = false
    
    def initialize(page_manager)
      @page_manager = page_manager
      @current_page = page_manager.page_number_start_value
      @is_started = false
    end

    def next_page
      @current_page += 1
      next_page_number = @page_manager.leading_zero && (@current_page + 1) < 10 ? "0#{@current_page}" : "#{@current_page}"
      case @page_manager.action_type
        when :get
          next_page = @page_manager.cartridge.base_list_template.gsub('$page_number', next_page_number)
          visit next_page
        when :click
          # debugger
          initial_visit unless @is_started
          find(:xpath, @page_manager.action_value).click
        when :js
          initial_visit unless @is_started
          execute_script(@page_manager.action_value.gsub!('$page_number', next_page_number))
      end
      sleep @page_manager.delay_between_pages
    end

    private
    
    def initial_visit
      # debugger
      initial_page = @page_manager.cartridge.base_list_template.gsub('$page_number', @page_manager.page_number_start_value.to_s)
      visit initial_page
      @is_started = true
    end
  end

end
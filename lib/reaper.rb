# Reaping is a main entity of parser
# Parametres for initialization:
# { :limit => 0, :cartridge_id => nil, :is_checking => false }
class Reaper
  attr_reader :result

  class << self
    attr_accessor :construct_fpath, :construct_okpd_fpath
    attr_accessor :project_fpath, :project_okpd_fpath
    attr_accessor :supply_fpath, :supply_okdp_fpath
    attr_accessor :service_fpath
    # attr_accessor :research_fpath
  end

  @construct_fpath = 'config/work_type_codes/construct.yml'
  @construct_okpd_fpath = 'config/work_type_codes/construct_okpd.yml'
  @project_fpath = 'config/work_type_codes/project.yml'
  @project_okpd_fpath = 'config/work_type_codes/project_okpd.yml'
  @supply_fpath = 'config/work_type_codes/supply.yml'
  @supply_okdp_fpath = 'config/work_type_codes/supply_okpd.yml'
  @service_fpath = 'config/work_type_codes/service_okdp.yml'
  # @research_fpath = 'config/work_type_codes/research.yml'

  def initialize(source, args = {})
    @reaper_params = ReaperParams.new(source, args)
    load_work_type_codes
    log_started_parsing(@reaper_params.source.name)
  end

  def reap
    get_cartridges
    # debugger
    @cartridges.each do |cartridge|
      @reaper_params.status[:reaped_tenders_count] = 0
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
        debugger
        break if @reaper_params.reaped_enough?
        tender_status = {}
        tender_stub = EntityStub.new

        code = Grappler.new(cartridge.selectors.active.where(:value_type => :code_by_source).first, entity_id).grapple
        log_got_code(code)

        tender = @reaper_params.source.tenders.find_or_create_by(code_by_source: code)

        cartridge.selectors.data_fields.order_by(priority: :desc).each do |selector|
          log_start_grappling(selector.value_type)

          value = Grappler.new(selector, entity_id).grapple
          tender_stub.insert(selector.value_type.to_sym, value)
          apply_rules(value, selector) if selector.got_rule?

          log_got_value(selector.value_type, value)
        end

        tender.id_by_source = entity_id
        tender.source_link = cartridge.base_link_template.gsub('$entity_id', entity_id)
        tender.group = cartridge.tender_type
        tender.documents = get_docs(cartridge, entity_id) if cartridge.selectors.where(value_type: :doc_title).count > 0
        tender.work_type = get_work_type(cartridge, entity_id) if cartridge.selectors.where(value_type: :work_type_code).count > 0
        tender.external_work_type = set_external_work_type_code(tender.work_type) unless tender.work_type.nil?
        tender.external_work_type = -1 if tender.work_type.nil?

        @reaper_params.status[:fields_status].each_pair do |field, status|
          tender_status[:state] = status
          tender_status[:failed_fields] ||= []
          tender_status[:failed_fields] << field if status == :failed

          tender_status[:fields_for_moderation] ||= []
          tender_status[:fields_for_moderation] << field if status == :moderation
        end

        tender.status = tender_status
        tender.update_attributes!(tender_stub.attributes) unless @reaper_params.args[:is_checking]
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
    @cartridges = @cartridges.where(_id: @cartridge_id) if @reaper_params.args[:cartridge_id]
  end

  def apply_rules(value, selector)
    return nil if selector.rules.count.zero?
    arbiter = Arbiter.new(value, selector.rule.first)
    @reaper_params.status[:fields_status][selector.value_type] = arbiter.judge
  end

  def get_ids(cartridge)
    Grappler.new(cartridge.selectors.active.ids_set.first).grapple_all.uniq
  end

  def get_docs(cartridge, entity_id)
    documents = []
    doc_title_sl = cartridge.selectors.where(value_type: :doc_title).first
    doc_link_sl = cartridge.selectors.where(value_type: :doc_link).first

    if doc_title_sl && doc_link_sl
      doc_titles = Grappler.new(doc_title_sl, entity_id.to_s).grapple_all
      doc_links = Grappler.new(doc_link_sl, entity_id.to_s).grapple_all

      i = 0
      doc_titles.each do |title|
        documents << { doc_title: title, doc_link: doc_links[i] }
        i += 1
      end
    end
    documents
  end

  def get_work_type(cartridge, entity_id)
    work_types = []

    work_type_codes = Grappler.new(cartridge.selectors.where(:value_type => :work_type_code).first, entity_id.to_s).grapple
    work_type_titles = Grappler.new(cartridge.selectors.where(:value_type => :work_type_title).first, entity_id.to_s).grapple

    i = 0
    work_type_codes.each do |code|
      next if code.nil?
      work_types << { 'code' =>  code, 'title' => work_type_titles[i] }
      i += 1
    end

    work_types
  end

  def load_work_type_codes
    # @construct_keys 1
    # @project_keys 2
    # @research_keys 3
    # @supply_keys 4
    # @service_keys 5

    @construct_keys = YAML.load_file(Reaper.construct_fpath).keys
    @construct_keys += YAML.load_file(Reaper.construct_okpd_fpath).keys
    @project_keys = YAML.load_file(Reaper.project_fpath).keys
    @project_keys += YAML.load_file(Reaper.project_okpd_fpath).keys
    # @research_keys = YAML.load_file(Reaper.research_fpath).keys
    @supply_keys = YAML.load_file(Reaper.supply_fpath).keys
    @supply_keys += YAML.load_file(Reaper.supply_okdp_fpath).keys
    @service_keys = YAML.load_file(Reaper.service_fpath).keys
  end

  def set_external_work_type_code(work_type)
    e_work_type = 0
    return -1 unless work_type.count > 0

    work_type.each do |w|
      next if w['code'].blank?

      e_work_type = 1 if @construct_keys.include?(w['code'])
      e_work_type = 2 if @project_keys.include?(w['code'])
      # e_work_type = 3 if @research_keys.include? w['code']
      e_work_type = 4 if @supply_keys.include?(w['code'])
      e_work_type = 5 if @service_keys.include?(w['code'])

      if w['code'].exclude?('.')
        e_work_type = 1 if w['code'].start_with?('451', '452', '453', '454')
        e_work_type = 2 if w['code'].start_with?('456')
        e_work_type = 4 if w['code'].start_with?('455', '459')
      else
        e_work_type = 1 if w['code'].start_with?('45')
        e_work_type = 2 if w['code'].start_with?('74.2')
      end
    end

    e_work_type
  end
end

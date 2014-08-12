# Reaping is a main entity of parser
# Parametres for initialization:
# { :limit => 0, :cartridge_id => nil, :is_checking => false }
class Reaper
  attr_reader :result

  def initialize(source, args = {})
    @params = ReaperParams.new(source, args)

    @display_manager = DisplayManager.new
    @display_manager.start

    @nav_manager = NavigationManager.new

    log_started_parsing(@params.source.name)
  end

  def reap
    @cartridges = get_cartridges

    @cartridges.each do |cartridge|
      ids_set = []

      @params.status[:reaped_tenders_count] = 0
      @nav_manager.load(cartridge.load_pm)

      while @params.args[:limit] > ids_set.count
        @nav_manager.next_page if ids_set.count < @params.args[:limit]
        ids_set += get_ids(cartridge)
      end
      log_got_ids_set(ids_set.count)

      ids_set.each do |entity_id|
        break if @params.reaped_enough?
        tender_status = {}
        tender_stub = EntityStub.new

        code = Grappler.new(cartridge.load_selector(:code_by_source), entity_id).grapple
        log_got_code(code)

        tender = @params.source.tenders.find_or_create_by(code_by_source: code)

        cartridge.selectors.data_fields.order_by(priority: :desc).each do |s|
          log_start_grappling(s.value_type)

          @nav_manager.go(s.link_template.gsub('$entity_id', entity_id.to_s))

          value = Grappler.new(s, entity_id).grapple
          tender_stub.insert(s.value_type.to_sym, value)
          apply_rules(value, s) if s.got_rule?

          log_got_value(s.value_type, value)
        end

        tender.id_by_source = entity_id
        tender.source_link = cartridge.base_link_template.gsub('$entity_id', entity_id)
        tender.group = cartridge.tender_type
        tender.documents = get_docs(cartridge, entity_id)
        tender.work_type = get_work_type(cartridge, entity_id)
        tender.external_work_type = WorkTypeProcessor.new(tender.work_type).process

        @params.status[:fields_status].each_pair do |f, status|
          tender_status[:state] = status
          tender_status[:failed_fields] ||= []
          tender_status[:failed_fields] << f if status == :failed

          tender_status[:fields_for_moderation] ||= []
          tender_status[:fields_for_moderation] << f if status == :moderation
        end

        tender.status = tender_status
        tender.update_attributes!(tender_stub.attrs) unless @params.args[:is_checking]
        @params.status[:result] << tender

        @params.status[:reaped_tenders_count] += 1

        log_tender_saved(tender[:_id])

      end
    end
    @params.status[:result].first
  end

  private

  def get_cartridges
    return @params.source.load_cartridges unless @params.args[:cartridge_id]
    Cartridge.find(@params.args[:cartridge_id]).to_a
  end

  def apply_rules(value, selector)
    return nil if selector.rules.count.zero?
    arbiter = Arbiter.new(value, selector.rule.first)
    @params.status[:fields_status][selector.value_type] = arbiter.judge
  end

  def get_ids(cartridge)
    Grappler.new(cartridge.selectors.active.ids_set.first).grapple_all.uniq
  end

  def get_docs(cartridge, entity_id)
    doc_title_sl = cartridge.load_selector(:doc_title)
    doc_link_sl = cartridge.load_selector(:doc_link)

    return nil unless doc_title_sl && doc_link_sl

    documents = []
    @nav_manager.go(doc_title_sl.link_template.gsub('$entity_id', entity_id))

    doc_titles = Grappler.new(doc_title_sl, entity_id.to_s).grapple_all
    doc_links = Grappler.new(doc_link_sl, entity_id.to_s).grapple_all

    doc_titles.each_with_index do |title, i|
      documents << { doc_title: title, doc_link: doc_links[i] }
    end

    documents
  end

  def get_work_type(cartridge, entity_id)
    code_selector = cartridge.load_selector(:work_type_code)
    title_selector = cartridge.load_selector(:work_type_title)

    return nil unless code_selector && title_selector

    work_types = []
    @nav_manager.go(code_selector.link_template.gsub('$entity_id', entity_id))

    wt_codes = Grappler.new(code_selector, entity_id).grapple_all
    wt_titles = Grappler.new(title_selector, entity_id).grapple_all

    wt_codes.each_with_index do |code, i|
      work_types << { 'code' =>  code, 'title' => wt_titles[i] }
    end

    work_types
  end
end

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
    @cartridges = load_cartridges

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
        tender_stub = EntityStub.new

        cartridge.selectors.data_fields.order_by(priority: :desc).each do |s|
          log_start_grappling(s.value_type)

          @nav_manager.go(s.link_template.gsub('$entity_id', entity_id.to_s))

          value = Grappler.new(s, entity_id).grapple
          tender_stub.insert(s.value_type.to_sym, value)

          log_got_value(s.value_type, value)
        end

        code = tender_stub.attributes[:code_by_source]
        tender = @params.source.tenders.find_or_create_by(code_by_source: code)
        old_md5 = tender.md5

        tender.id_by_source = entity_id
        tender.source_link = cartridge.base_link_template.gsub('$entity_id', entity_id)
        tender.group = cartridge.tender_type
        tender.external_work_type = WorkTypeProcessor.new(tender.work_type).process
        tender.update_attributes(emit_complex_selectors(cartridge, entity_id))

        unless @params.args[:is_checking]
          tender.update_attributes(tender_stub.attrs)
          tender.modified_at = Time.now unless old_md5 == tender.md5
          tender.save
        end

        @params.status[:result] << tender
        @params.status[:reaped_tenders_count] += 1

        log_tender_saved(tender[:_id])

        sleep(cartridge.delay_between_tenders) if cartridge.need_to_sleep?
      end
    end
    @params.status[:result].first
  end

  private

  def load_cartridges
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

  def emit_complex_selectors(cartridge, entity_id)
    result = {}

    Selector.complex_fields.each do |field, set|
      data = {}
      selector = nil

      set.each do |struct_key, selector_type|
        selector = cartridge.load_selector(selector_type)
        continue unless selector

        @nav_manager.go(selector.link_template.gsub('$entity_id', entity_id))

        data[struct_key] = Grappler.new(selector, entity_id).grapple_all
      end

      result[field] = []
      data[set.keys.first].each_with_index do |v, i|
        result[field] << { set.keys.first => v, set.keys.last => data[set.keys.last][i] }
      end
    end
    result
  end
end

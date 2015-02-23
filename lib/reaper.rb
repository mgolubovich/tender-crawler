# Reaping is a main entity of parser
# Parameters for initialization:
# { :limit => 0, :cartridge_id => nil, :is_checking => false }
class Reaper
  def initialize(source, args = {})
    @params = ReaperParams.new(source, args)
    @nav_manager = NavigationManager.new
    @hook = Grappler.new

    @proxy_manager = ProxyManager.new(source._id)
    @is_proxified = false
    @attempts_count = 0

    @log = ParserLog.new.logger
    @log.set_source(source._id)

    @log.info('start', source: source, args: args)
  end

  def reap
    @cartridges = load_cartridges

    @cartridges.each do |cartridge|

      @params.status[:reaped_tenders_count] = 0
      @nav_manager.load(cartridge.load_pm)

      ReapingStatistics.started_collecting_ids
      ids_set = get_ids_set(cartridge)
      ReapingStatistics.finished_collecting_ids

      ReapingStatistics.started_collecting_tenders
      enqueue_reap_task(cartridge, ids_set) unless ids_set.empty?
    end
    ReapingStatistics.finished_collecting_tenders

    ReapingStatistics.print_stats
  end

  def enqueue_reap_task(cartridge, ids_set)
    Resque.enqueue(ReapSourceIdsJob, cartridge._id, ids_set)
  end

  def enqueue_force_reap_task(cartridge, ids_set)
    Resque.enqueue(ReapSourceIdsForceJob, cartridge._id, ids_set)
  end

  def reap_ids(cartridge, ids_set)

    @nav_manager.load(cartridge.load_pm)

    ids_set.each do |entity_id|
      if @params.reaped_enough?
        @log.info('reaped enought', cartridge: cartridge, entity_id: entity_id)
        break
      end

      #check site availability
     # if site_available?
        tender_stub = EntityStub.new

        ReapingStatistics.started_collecting_tender(entity_id)

        cartridge.selectors.data_fields.order_by(priority: :desc).each do |s|
          @log.info('start grape',
                    cartridge: cartridge,
                    entity_id: entity_id,
                    selector: s)

          link = s.field_valid?(:link_template) ? s.url(entity_id) : cartridge.tender_url(entity_id)
          @nav_manager.go(link)

          value = @hook.load(s).grapple
          tender_stub.insert(s.value_type.to_sym, value)

          @log.info('got value',
                    cartridge: cartridge,
                    entity_id: entity_id,
                    selector: s,
                    value: value)
        end

        code = tender_stub.attributes[:code_by_source]

        code = code.to_s.empty? ? entity_id : code
        tender = @params.source.tenders.find_or_create_by(code_by_source: code)

        if tender.as_document[:moderated_by].nil?
          old_md5 = tender.md5
          old_is_valid = tender.is_valid?

          tender.id_by_source = entity_id
          tender.source_link = cartridge.tender_url(entity_id)
          tender.group = cartridge.tender_type
          tender.update_attributes(emit_complex_selectors(cartridge, entity_id))
          tender.update_attributes(tender_stub.attrs)
          tender.modified_at = Time.now unless old_md5 == tender.md5
          tender.cartridge_id = cartridge._id

          # @TODO refactor to model method
          if tender.external_work_type.nil?
            if tender.group == :bankrupt
              tender.external_work_type = WorkTypeProcessor::BANKRUPT_WORK_TYPE
            else
              tender.external_work_type = WorkTypeProcessor.new(tender.work_type).process
            end
          end

          tender.delete if (!tender.is_valid? && !old_is_valid)

          if !@params.args[:is_checking] && tender.is_valid?
            tender.save!
            # dirty hack for unfreeze
            @log.info('tender saved', tender: tender.as_document.dup)
          else
            screen = Capybara.page.driver.render_base64

            @log.error('tender invalid',
                       tender: tender.as_document.dup,
                       cartridge: cartridge,
                       screen: screen)
          end

          @params.status[:reaped_tenders_count] += 1

          ReapingStatistics.finished_collecting_tender(entity_id)


          sleep(cartridge.delay_between_tenders) if cartridge.need_to_sleep?
        else
          @log.error('tender already moderated', tender: tender.as_document.dup)
        end
    #  else
    #    @log.error('site is not available', cartridge: cartridge, entity_id: entity_id)
    #  end
    end
  end

  def get_ids_set(cartridge)
    cur_page = 1
    ids_set = []
    contains_attempt_count = 0
    while @params.args[:limit] > ids_set.count

      if ids_set.count < @params.args[:limit]
        @nav_manager.next_page
      else
        @log.info('stop collect ids by limit',
                  count: ids_set.count,
                  cartridge: cartridge)
      end

      ids_slice = get_ids(cartridge)
      @log.info('got ids slice', ids_slice: ids_slice, page: cur_page)

      if ids_slice.size > 0 && ids_set.contains?(ids_slice)
        screen = Capybara.page.driver.render_base64
        @log.error('collect contains',
                   ids_slice: ids_slice,
                   page: cur_page,
                   cartridge: cartridge,
                   screen: screen)
        contains_attempt_count += 1
      else
        contains_attempt_count = 0
        ids_set += ids_slice
        cur_page += 1
      end

      if ids_slice.size.zero?
        screen = Capybara.page.driver.render_base64
        @log.error('empty slice',
                   page: cur_page,
                   contains_count: contains_attempt_count,
                   cartridge: cartridge,
                   screen: screen
        )
        break unless @proxy_manager.save_the_day
      end

      if contains_attempt_count > 5
        screen = Capybara.page.driver.render_base64
        @log.error('Failed by contains',
                   ids_slice: ids_slice,
                   page: cur_page,
                   contains_count: contains_attempt_count,
                   cartridge: cartridge,
                   screen: screen
        )
        contains_attempt_count = 0

        if ids_slice.empty? && ids_set.empty?
          # do not refactor as one line!
          break unless @proxy_manager.save_the_day
        end
      end
    end

    @log.info('got ids set',
              ids_set: ids_set,
              cartridge: cartridge,
              pages: cur_page)
    ids_set
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
    @hook.load(cartridge.selectors.active.ids_set.first).grapple_all.uniq
  end

  def site_available?(cartridge)
    !@hook.load(cartridge.selectors.active.availability_check.first).grapple.empty?
  end

  def emit_complex_selectors(cartridge, entity_id)
    result = {}

    Selector.complex_fields.each do |field, set|
      data = {}
      master = set.keys.first
      slave = set.keys.last
      stub = EntityStub.new

      set.each do |struct_key, selector_type|
        selectors = cartridge.load_selectors(selector_type)
        next if selectors.empty?
        selectors.each do |s|
          link = s.field_valid?(:link_template) ? s.url(entity_id) : cartridge.tender_url(entity_id)
          @nav_manager.go(link, entity_id)
          stub.insert(struct_key, @hook.load(s).grapple_all)
        end
        data[struct_key] = stub.attrs[struct_key]
      end

      result[field] = []

      next if data.empty?
      data[master].each_with_index do |v, i|
        result[field] << { master => v, slave => data[slave][i] }
      end
    end
    result
  end
end

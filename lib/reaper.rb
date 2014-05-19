require 'debugger'
class Reaper

  attr_reader :result
  
  def initialize(source, limit=0)
    @source = source
    @limit = limit
  end

  def reap
    log_started_parsing(@source.name)

    selector_groups = @source.selectors.distinct(:group)
    ParserLog.logger.info("Got groups - #{selector_groups}")
    @result = []

    selector_groups.each do |group|
      ids_set = Grappler.new(@source.selectors.active.ids_set.where(:group => group.to_s).first).grapple_all.uniq
      log_got_ids_set(ids_set.count)

      selectors = @source.selectors.active.data_fields.where(:group => group)

      ids_set.each do |entity_id|
        fields_status = Hash.new
        tender_status = Hash.new

        # HACK Fix later
        entity_id = entity_id.first if entity_id.is_a?(Array)
        #
        code = Grappler.new(selectors.active.where(:value_type => :code_by_source).first, entity_id).grapple
        log_got_code(code)

        tender = @source.tenders.find_or_create_by(code_by_source: code)

        selectors.each do |selector|
          log_start_grappling(selector.value_type)
          value = Grappler.new(selector, entity_id).grapple
          
          # GOVNOKOD
          if selector.value_type.to_sym == :start_price
            tender[selector.value_type.to_sym] = value.to_f
          else
            tender[selector.value_type.to_sym] = value
          end
          
          fields_status[selector.value_type.to_sym] = Arbiter.new(value, selector.rule.first).judge if selector.rules.count > 0
          
          log_got_value(selector.value_type, value)
        end

        tender.id_by_source = entity_id
        tender.source_link = @source.external_link_templates[group.to_s].gsub('$entity_id', entity_id)
        tender.group = group
        
        fields_status.each_pair do |field, status|
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
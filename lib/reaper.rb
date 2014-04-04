class Reaper

  attr_reader :result
  
  def initialize(source, limit=0)
    @source = source
    @limit = limit
  end

  def reap
    selector_groups = @source.selectors.distinct(:group)
    @result = []
    @hook = Grappler.new

    selector_groups.each do |group|
      @hook.charge(@source.selectors.active.ids_set.where(:group => group).first)
      ids_set = @hook.grapple_all.uniq
      selectors = @source.selectors.active.data_fields.where(:group => group)

      ids_set.each do |entity_id|
        code = @hook.charge(selectors.active.where(:value_type => :code_by_source).first, entity_id).grapple
        tender = @source.tenders.find_or_create_by(code_by_source: code)
        
        selectors.each do |selector|
          tender[selector.value_type] = @hook.charge(selector, entity_id).grapple
        end

        tender.id_by_source = entity_id
        tender.source_link = @source.external_link_templates[group.to_s].gsub('$entity_id', entity_id)
        tender.group = group

        tender.save
        @result << tender
      end
    end
  end

end
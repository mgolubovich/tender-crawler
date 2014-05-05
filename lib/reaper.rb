class Reaper

  attr_reader :result
  
  def initialize(source, limit=0)
    @source = source
    @limit = limit
  end

  def reap
    selector_groups = @source.selectors.distinct(:group)
    @result = []

    selector_groups.each do |group|
      ids_set = Grappler.new(@source.selectors.active.ids_set.where(:group => group).first).grapple_all.uniq
      selectors = @source.selectors.active.data_fields.where(:group => group)

      ids_set.each do |entity_id|
        code = Grappler.new(selectors.active.where(:value_type => :code_by_source).first, entity_id).grapple
        tender = @source.tenders.find_or_create_by(code_by_source: code)

        selectors.each do |selector|
          value = Grappler.new(selector, entity_id).grapple
          tender[selector.value_type.to_sym] = value
        end

        tender.id_by_source = entity_id
        tender.source_link = @source.external_link_templates[group.to_s].gsub('$entity_id', entity_id)
        tender.group = group

        tender.save
      end
    end
  end

end
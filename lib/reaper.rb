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
        tender = @source.tenders.find_or_create_by(id_by_source: entity_id)
        tender.id_by_source = entity_id
        
        tender.title = Grappler.new(selectors.where(:value_type => :title).first, entity_id).grapple
        tender.tender_form = Grappler.new(selectors.where(:value_type => :tender_form).first, entity_id).grapple
        tender.customer_name = Grappler.new(selectors.where(:value_type => :customer_name).first, entity_id).grapple
        tender.customer_adress = Grappler.new(selectors.where(:value_type => :customer_adress).first, entity_id).grapple
        tender.code_by_source =  Grappler.new(selectors.where(:value_type => :code_by_source).first, entity_id).grapple
        tender.start_at = Grappler.new(selectors.where(:value_type => :start_at).first, entity_id).grapple
        tender.published_at = Grappler.new(selectors.where(:value_type => :published_at).first, entity_id).grapple

        tender.source_link = @source.external_link_templates[group.to_s].gsub('$entity_id', entity_id)
        tender.group = group

        tender.save
        @result << tender
      end
    end
  end

end
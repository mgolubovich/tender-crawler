class GrapplingManager
  
  attr_reader :source, :data

  def initialize(source, depth=0)
    @source = source
    @depth = depth
    @data = []
    @hook = Grappler.new
  end

  def manage
    selector_groups = @source.selectors.distinct(:group)
    selector_groups.each do |group|
      selectors = @source.selectors.active.data_fields.where(group: group)
      ids_set = @hook.charge(@source.selectors.active.ids_set.first).grapple_all

      @data << extract_data(selectors, ids_set)
    end
  end

  def extract_data(selectors, ids_set)
    tmp_data = []

    ids_set.each do |entity_id|
      segment = Hash.new    
      selectors.each do |selector|
        segment[selector.value_type] = @hook.charge(selector, entity_id).grapple(selector.grapple_mode)
      end
      tmp_data << segment
    end
    
    tmp_data
  end

end
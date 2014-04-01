class Reaper

  def initialize(source, limit=0)
    @source = source
    @limit = limit

    reap
  end

  def reap
    selector_groups = @source.selectors.distinct(:group)
    selector_groups.each do |group|
      ids_set = Grappler.new(@source.selectors.ids_set.active.where(:group => group).first).grapple_all
    end
  end

  def get_ids_set(group)

  end

end
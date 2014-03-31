class Reaper

  def initialize(source, limit=0)
    @source = source
    @limit = limit
  end

  def reap
    @selectors = @source.selectors.where(:value_type => :last_id).group(:group)
  end
end
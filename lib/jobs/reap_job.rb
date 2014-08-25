module ReapJob
  @queue = :top

  def self.perform ( source_id, deep_level )
    Reaper.new(Source.find(source_id), {:limit => deep_level.to_i}).reap
  end
end
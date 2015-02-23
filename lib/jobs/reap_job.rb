require 'resque/plugins/queue/lock'

class ReapJob
  extend Resque::Plugins::Queue::Lock

  @queue = :top


  def self.queue_lock(source_id, deep_level)
    "source_#{source_id['$oid']}"
  end

  def self.perform(source_id, deep_level)
    Reaper.new(Source.find(source_id['$oid']), {:limit => deep_level.to_i}).reap
  end
end

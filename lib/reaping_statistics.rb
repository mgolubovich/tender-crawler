# Class that collects and stores statistics data during reaping process
class ReapingStatistics
  class << self
    attr_accessor :time_store
    attr_accessor :transition_store
    attr_accessor :general_store
  end

  @time_store = {}
  @transition_store = {}

  @general_store = {}
  @general_store[:tenders] = {}

  # General time mesures
  def self.started_collecting_ids
    ReapingStatistics.time_store[:started_collecting_ids] = DateTime.now
  end

  def self.finished_collecting_ids
    ReapingStatistics.time_store[:finished_collecting_ids] = DateTime.now
  end

  def self.started_collecting_tenders
    ReapingStatistics.time_store[:started_collecting_tenders] = DateTime.now
  end

  def self.finished_collecting_tenders
    ReapingStatistics.time_store[:finished_collecting_tenders] = DateTime.now
  end

  # Tenders
  def self.started_collecting_tender(id)
    ReapingStatistics.general_store[:tenders][id.to_sym] = {}
    ReapingStatistics.general_store[:tenders][id.to_sym][:started_at] = DateTime.now
  end

  def self.finished_collecting_tender(id)
    finished_at = DateTime.now
    started_at = ReapingStatistics.general_store[:tenders][id.to_sym][:started_at]

    ReapingStatistics.general_store[:tenders][id.to_sym][:finished_at] = finished_at
    ReapingStatistics.general_store[:tenders][id.to_sym][:duration] = finished_at.difference_in_seconds(started_at)
  end

  def self.print_stats
    puts ReapingStatistics.time_store
    puts ReapingStatistics.general_store
  end
end

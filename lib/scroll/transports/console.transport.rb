class ConsoleTransport
  def initialize (level)
    @level = :debug
    @levels = [:info, :debug]

    @level = level if @levels.include?(level)
    @storage = ConsoleStorage.new
  end

  def log(data)
    @storage.save(self.send(@level, data))
  end

  def info(data)
    data.join(" (info) ")
  end

  def debug(data)
    data.join(" (debug) ")
  end
end
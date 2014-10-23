class FileTransport
  def initialize (level)
    @level = :debug
    @levels = [:info, :debug]
    
    @level = level if @levels.include?(level)
    @storage = FileStorage.new @level.to_s + "_file.log"
  end

  def log(data)
    @storage.save(self.send(@level, data))
  end

  def info(data)
    data.join(" (info) ") + "\n"
  end

  def debug(data)
    data.join(" (debug) ") + "\n"
  end
end
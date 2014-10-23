class Scroll
  def initialize (transport, level)
    @transports = {
      file:             "FileTransport",
      mongodb:          "MongodbTransport",
      console:          "ConsoleTransport",
      reaper_process:   "ReaperProcessTransport",
      reaper_minimal:   "ReaperMinimalTransport"
    }

    @transport = Object.const_get(@transports[transport]).new level
  end

  def log (data)
    @transport.log(data)
  end
end
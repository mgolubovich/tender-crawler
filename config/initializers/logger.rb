require 'logger'

class ParserLog
  LOG_FILEPATH = 'log/parser.log'

  # Start logging in given file, keeping 10 old logfiles, rotating if size og log file exceeds 1Gb
  @logger = Logger.new(LOG_FILEPATH, 10, 100 * 1024 * 1024 * 1024)
  @logger.level = Logger::WARN

  def self.logger
    @logger
  end

  def self.logger=(new_logger)
    @logger = new_logger
  end
end
require 'time'

class BaseLog
  attr_reader :logger
  IDENTIFIER = 'base'

  def initialize(source_id=nil)
    @logger = MongoLogger.new(self.class::IDENTIFIER)
    @logger.set_source(source_id)
  end
end

class ParserLog < BaseLog
  IDENTIFIER = 'parser'
end

class ImportLog < BaseLog
  IDENTIFIER = 'import'
end

class DatafixLog < BaseLog
  IDENTIFIER = 'datafix'
end

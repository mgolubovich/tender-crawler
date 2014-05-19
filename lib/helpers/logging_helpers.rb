require 'time'

def log_started_parsing(entity)
  ParserLog.logger.info "[#{Time.now}] - started parsing for #{entity}"
end

def log_got_selectors(count)
  ParserLog.logger.info "[#{Time.now}] - got selectors, count = #{count}"
end

def log_got_ids_set(count)
  ParserLog.logger.info "[#{Time.now}] - got ids set, count = #{count}"
end

def log_got_code(code)
  ParserLog.logger.info "[#{Time.now}] - got original code from source = #{code}"
end

def log_got_value(value_type, value)
  ParserLog.logger.info "[#{Time.now}] - got value for #{value_type} = #{value}"
end

def log_start_grappling(value_type)
  ParserLog.logger.info "[#{Time.now}] - start grappling for #{value_type}"
end

def log_tender_saved(tender_id)
  ParserLog.logger.info "[#{Time.now}] - tender ##{tender_id} saved"
end

def log_rule_failed(rule, value)
  ParserLog.logger.info "[#{Time.now}] - #{rule} failed on '#{value}'"
end
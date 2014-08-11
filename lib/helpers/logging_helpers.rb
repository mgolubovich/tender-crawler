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

def log_start_import(entity)
  ImportLog.logger.info "[#{Time.now}] - started import for #{entity}"
end

def log_started_import(records_count, slice_size)
  ImportLog.logger.info "[#{Time.now}] - started import with LIMIT #{records_count} OFFSET #{slice_size}"
end

def log_import_id(id, code)
	ImportLog.logger.info "[#{Time.now}] - got ##{id} with original code from source = #{code}"
end

def log_import_source_id(source_id, source_name)
  ImportLog.logger.info "[#{Time.now}] - source is #{source_name} (#{source_id})"
end

def log_import_group(group, site_id)
  ImportLog.logger.info "[#{Time.now}] - site_id is #{site_id}, group = #{group}"
end

def log_import_badgroup
	ImportLog.logger.info "[#{Time.now}] - site_id is empty"
end

def log_import_doc_wt(documents, work_type)
	ImportLog.logger.info "[#{Time.now}] - documents = #{documents}, okdp = #{work_type}"
end

def log_import_save(tender_id)
	ImportLog.logger.info "[#{Time.now}] - tender ##{tender_id} saved"
end

def log_import_attributes(atr)
	ImportLog.logger.info "[#{Time.now}] - was copied #{atr}"
end

def log_import_eid(eid)
	ImportLog.logger.info "[#{Time.now}] - new external_id is #{eid}"
end

def log_import_new(tender_id)
	ImportLog.logger.info "[#{Time.now}] - create new tender with ##{tender_id}"
end

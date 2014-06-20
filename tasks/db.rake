require 'rubygems'
require 'active_record'
require 'mysql2'
require 'debugger'



ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  encoding: 'utf8',
  database: 'zakazrf',
  username: 'auktion',
  password: 'Je8tja$wPmn[kR93',
  host:     '10.0.105.17'
)

namespace :db do
  desc "Import tenders from MySQL db"
  task :import_from_mysql, :records_count, :slice_size do |t, args|
    assoc_source = YAML.load_file('config/source_id_assoc.yml')
    i = 0
    ABYSS = '53a0152790c043c46500000b'
    current_eid = Tender.max(:external_db_id).to_i
    query = "Select * FROM tenders WHERE 1 LIMIT #{args.records_count} OFFSET #{i * args.slice_size.to_i}"
    puts "Let's start. #{query}"
    slice_size = i * args.slice_size.to_i
    log_started_import(args.records_count, slice_size)
    records = ActiveRecord::Base.connection.exec_query(query)
    records.each do |record|
    	log_import_id(record["id"], record["code"])
      if assoc_source[record["site_id"]]
      	source_id = assoc_source[record["site_id"]].first
      else
      	source_id = ABYSS
      end
      source_name = Source.find(source_id).name
      log_import_source_id(source_id, source_name)
      mongo_tender = Tender.find_or_create_by(code_by_source: record["code"], source_id: source_id)
      if assoc_source[record["site_id"]]
      	mongo_tender.group = assoc_source[record["site_id"]][1]
      	log_import_group(mongo_tender.group, record["site_id"])
      end
      log_import_badgroup() if assoc_source[record["site_id"]].nil?
      # debugger
      unless mongo_tender.external_db_id.to_i > 0
      	current_eid += 1
        mongo_tender.external_db_id = current_eid
        log_import_new(mongo_tender._id)
        log_import_eid(mongo_tender.external_db_id)
      end
      mongo_tender.title = record["title"]
      mongo_tender.start_price = record["start_price"].to_f
      mongo_tender.source_link = record["link"]
      mongo_tender.tender_form = record["tender_form"]
      mongo_tender.customer_name = record["customer"]
      mongo_tender.customer_address = record["address"]
      mongo_tender.customer_inn = record["customer_inn"]
      mongo_tender.external_city_id = record["city_id"].to_i
      mongo_tender.external_work_type = record["work_type_key"].to_i
      mongo_tender.external_region_id = record["region_id"].to_i
      mongo_tender.start_at = record["start_at"]
      mongo_tender.published_at = record["public_at"]
      mongo_tender.created_at = record["created"]
      mongo_tender.updated_at = record["updated"]

      unless record["documents"].nil?
	      mysql_doc = JSON.parse(record["documents"])
	      documents = []
	      mysql_doc.each_pair do |title, link|
	      	documents << {"doc_title" => title, "doc_link" => link}
	      end
	    mongo_tender.documents = documents
      end
      unless record["okdps"].nil?
	      mysql_okdps = JSON.parse(record["okdps"])
	      work_type = []
	      mysql_okdps.each_pair do |code, title|
	      	work_type << {"code" => code, "title" => title}
	      end
	    mongo_tender.work_type = work_type
      end
	  #  log_import_doc_wt(mongo_tender.documents, mongo_tender.work_type)
	  	log_import_attributes(mongo_tender.attributes)
      mongo_tender.save
      log_import_save(mongo_tender._id)
      puts "Tender ##{record["id"]} was saved in #{source_name} (#{source_id})"
      i += 1
    end
  end
end

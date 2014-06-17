require 'rubygems'
require 'active_record'
require 'mysql2'
require 'debugger'
#LOGS in tux
require 'logger'
ActiveRecord::Base.logger = Logger.new(STDERR)


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
    records = ActiveRecord::Base.connection.exec_query(query)
    records.each do |record|
      if assoc_source[record["site_id"]]
      	source_id = assoc_source[record["site_id"]].first
      #	puts "good: #{source_id}"
      else
      	source_id = ABYSS
      #	puts "abysstop: #{source_id}"
      end
      mongo_tender = Tender.find_or_create_by(code_by_source: record["code"], source_id: source_id)
      if assoc_source[record["site_id"]]
      	mongo_tender.group = assoc_source[record["site_id"]][1]
      end
    #  debugger
      current_eid += 1
    	mongo_tender.external_db_id = current_eid
      mongo_tender.title = record["title"]
      mongo_tender.start_price = record["start_price"].to_f
      mongo_tender.source_link = record["link"]
      mongo_tender.tender_form = record["tender_form"]
      mongo_tender.customer_name = record["customer"]
      mongo_tender.customer_address = record["address"]
      mongo_tender.customer_inn = record["customer_inn"]
      mongo_tender.external_city_id = record["city_id"].to_i
      mongo_tender.external_work_type = record["work_type"].to_i
      mongo_tender.external_region_id = record["region_id"].to_i
      mongo_tender.start_at = record["start_at"]
      mongo_tender.published_at = record["public_at"]

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

      mongo_tender.save
      puts mongo_tender.code_by_source
      puts mongo_tender.source_id
      i += 1
    end
  end
end

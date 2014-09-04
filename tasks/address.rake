require 'active_record'
require 'mysql2'
require 'open-uri'
require 'net/http'


ActiveRecord::Base.establish_connection(
    adapter:  'mysql2',
    encoding: 'utf8',
    database: 'zakazrf',
    username: 'tester',
    password: 'Qwerty777',
    host:     '10.0.104.205'
)

namespace :address do

  DEFAULT_CITY_CODE = -1
  DEFAULT_REGION_CODE = -1

  ################ UPDATE ADDRESS LISTS ################

  desc "Update city collection from mysql"
  task :update_city_list do
    puts "Deleting all documents from collection"
    City.delete_all

    puts "Load cities from mysql"
    query = <<-SQL
      SELECT c.code, c.name, c.id_district, d.id_region
      FROM altasib_kladr_cities c
      LEFT JOIN altasib_kladr_districts d ON c.ID_DISTRICT = d.CODE
      WHERE c.status > 0
    SQL

    records = ActiveRecord::Base.connection.exec_query(query)

    progressbar = ProgressBar.create(:format => '%a %B %p%% %t %c/%C', :starting_at => 0, :total => records.count)
    records.each do |record|
      record["id_region"] = record["id_district"][0, 2] if record["id_region"].to_i == 0

      city = City.new
      city.city_code = record["code"].to_i
      city.name = record["name"].mb_chars.downcase
      city.region_code = record["id_region"].to_i
      city.save

      progressbar.increment
    end
  end

  desc "Update region collection from mysql"
  task :update_region_list do
    puts "Deleting all documents from collection"
    Region.delete_all

    reductions = YAML.load_file("config/dictionaries/region_reduction.yml").symbolize_keys!
    reduction_rules = YAML.load_file("config/dictionaries/region_reduction_rule.yml").symbolize_keys!
    region_alt_names = YAML.load_file("config/dictionaries/region_alt_names.yml").symbolize_keys!

    puts "Load cities from mysql"
    query = "SELECT code, name, full_name, socr FROM altasib_kladr_region"
    records = ActiveRecord::Base.connection.exec_query(query)

    progressbar = ProgressBar.create(:format => '%a %B %p%% %t %c/%C', :starting_at => 0, :total => records.count)
    records.each do |record|

      region_code = record["code"].to_i
      reduction = record["socr"]

      template = reduction_rules[:templates]["default"]
      unless reduction_rules[:rules][reduction].to_s.empty?
        alias_template = reduction_rules[:rules][reduction]["template"]

        unless reduction_rules[:rules][reduction]["regions"].nil?
          if reduction_rules[:rules][reduction]["regions"].has_key?(region_code)
            alias_template = reduction_rules[:rules][reduction]["regions"][region_code]
          end
        end
        template = reduction_rules[:templates][alias_template]
      end

      template_values = {
          :name => record["name"],
          :fullname => record["full_name"],
          :reduction => reductions[reduction.to_sym]
      }

      #Replace the values in the template
      name = template % template_values

      region = Region.new
      region.name = name.mb_chars.downcase
      region.alt_name = region_alt_names[region_code] if region_alt_names.include?(region_code)
      region.region_code = region_code
      region.save

      progressbar.increment
    end
  end

  desc "Update postcode collection from http://info.russianpost.ru/database/ops.html"
  task :update_postcode_list do
    zip_name = nil
    last_uri = nil

    #Download new database
    puts "Checking new version.."
    i = 1
    loop do
      num = i.to_s.rjust(2, "0")
      uri = URI.parse("http://info.russianpost.ru/database/PIndx#{num}.zip")
      http = Net::HTTP.start(uri.host, uri.port)

      if http.head(uri.request_uri).code == "200"
        zip_name = "data/postcodes/#{File.basename(uri.path)}"
        last_uri = uri
        i += 1
      else
        break
      end
    end

    abort "URL error" if zip_name.nil?
    abort "Latest version. No need to update." if File.exist?(zip_name)

    puts "Downloading new database.."

    open(last_uri.to_s) do |zip_in|
      File.open(zip_name, "w") do |zip_out|
        zip_out.write(zip_in.read)
      end
    end

    tmp_files = []
    Zip::ZipFile.open(zip_name) do |zip_files|
      zip_files.each do |file|
        path = File.join("data/postcodes/tmp/", file.name)
        zip_files.extract( file, path )
        tmp_files.append(path)
      end
    end

    #Update collection
    puts "Deleting all documents from collection.."
    Postcode.delete_all

    regions = {}

    Region.all.to_a.each do |region|
      regions[region.name] = region.region_code
    end

    autonomous_regions = [
        "ханты-мансийский-югра автономный округ",
        "ненецкий автономный округ",
        "чукотский автономный округ",
        "еврейская автономная область"
    ]

    puts "Updating documents in collection.."

    no_founds = []
    dbf_table = DBF::Table.new(tmp_files[0])
    progressbar = ProgressBar.create(:format => '%a %B %p%% %t %c/%C', :starting_at => 0, :total => dbf_table.count)
    dbf_table.each do |record|
      region = record[:region].mb_chars.downcase.to_s

      autonomous_region = record[:autonom].mb_chars.downcase.to_s
      region = autonomous_region if autonomous_regions.include? autonomous_region

      #Some exceptions
      case region
        when "северная осетия-алания республика"
          region = "республика северная осетия - алания"

        when "чувашская республика"
          region = "чувашская республика - чувашия"

        when "саха (якутия) республика"
          region = "республика саха /якутия/"

        when "ханты-мансийский-югра автономный округ"
          region = "ханты-мансийский автономный округ - югра"

        else
          #Если регион не находится и содержит слово "республика", перемещаем слово в начало
          if regions[region].nil? && region.include?("республика")
            region = region.split(" ")
            region = region.unshift(region.pop).join(" ")
          end
      end

      if regions[region].nil?
        puts "#{record[:index]} | #{record[:opsname]}" if region.empty?
        no_founds.append(region) unless no_founds.include? region
      else
        postcode = Postcode.new
        postcode.postcode = record[:index]
        postcode.region_code = regions[region]
        postcode.save
      end

      progressbar.increment
    end

    puts "\nNot found regions:"
    no_founds.each { |region| puts " - #{region}"}
    File.delete(tmp_files[0])
    puts "\nUpdate is complete"
  end

  ################ SET REGION CODE FOR TENDERS ################

  desc "Set regions for tenders"
  task :set_regions_in_tenders_for, :source_id do |t, args|
    tenders = Source.find(args.source_id).tenders.where(:customer_address.ne => nil).where(:region_code => nil)
    regions = Region.all.to_a

    tenders.each do |t|
      regions.each do |r|
        t.region_code = r.region_code if t.customer_address.include? r.name
      end
      t.save
    end
  end

  desc "Set regions and cities for tenders by postcode; source_id=none for all tenders; modes: new(region code is null, default), indefinite(region code equally -1), all"
  task :set_region_code_for_tenders_by_postcode, :source_id, :mode do |t, args|
    args.with_defaults(:source_id => :none, :mode => :new)

    tenders = Tender
    tenders = tenders.where(source_id: args.source_id) unless args.source_id.to_sym == :none

    case args.mode.to_sym
      when :indefinite
        tenders = tenders.where(region_code: -1).to_a
      when :all
        tenders = tenders.all.to_a
      else
        tenders = tenders.where(region_code: nil).to_a
    end

    cities = {}
    City.all.each do |city|
      cities[city.region_code] = {} if cities[city.region_code].nil?
      cities[city.region_code][city.name] = city.city_code
    end


    progressbar = ProgressBar.create(:format => '%a %B %p%% %t %c/%C', :starting_at => 0, :total => tenders.count)
    tenders.each do |tender|
      unless tender.customer_address.nil? || tender.customer_address.empty?
        address_postcode = /\b[0-9]{6}\b/.match(tender.customer_address).to_s

        unless address_postcode.empty?
          postcode = Postcode.where(postcode: address_postcode).first

          unless postcode.nil?
            tender.city_code = nil
            unless cities[postcode.region_code].nil?
              cities[postcode.region_code].each do |city_code, city_name|
                unless /(^|.*[^а-я])#{city_name}([^а-я].*|$)/i.match(tender.customer_address).to_s.empty?
                  tender.city_code = city_code
                  break
                end
              end
            end

            tender.region_code = postcode.region_code
            tender.save
          end
        end
      end

      progressbar.increment
    end
  end

  desc "[REVERSE VERSION] Set regions for tenders; source_id=none for all tenders; modes: new(region code is null, default), indefinite(region code equally -1), all"
  task :set_region_code_for_tender_reverse, :source_id, :mode do |t, args|
    args.with_defaults(:source_id => :none, :mode => :new)

    regions = Region.all.to_a
    progressbar = ProgressBar.create(:format => '%a %B %p%% %t %c/%C', :starting_at => 0, :total => regions.count)

    regions.each do |region|
      tenders = Tender
      tenders = tenders.where(source_id: args.source_id) unless args.source_id == :none
      tenders = tenders.any_of({:customer_address => /(^|.*[^а-я])#{region.name}([^а-я].*|$)/i})
      case args.mode.to_sym
        when :indefinite
          tenders = tenders.where(region_code: -1).to_a
        when :all
          tenders = tenders.to_a
        else
          tenders = tenders.where(region_code: nil).to_a
      end

      tenders.each do |tender|
        tender.region_code = region.region_code
        tender.save
      end

      progressbar.increment
    end
  end

  ################ SET CITY CODE FOR TENDERS ################

  desc 'Set cities for tenders'
  task :set_cities_in_tenders_for, :source_id do |t, args|
    tenders = Source.find(args.source_id).tenders.where(:customer_address.ne => nil).where(:city_code => nil)
    cities = City.all.to_a

    tenders.each do |t|
      cities.each do |c|
        t.city_code = c.city_code if t.customer_address.include? c.name
      end
      t.save
    end
  end

  desc "[REVERSE VERSION] Set cities for tenders; source_id=none for all tenders; modes: new(region code is null, default), indefinite(region code equally -1), all"
  task :set_city_code_for_tender_reverse, :source_id, :mode do |t, args|
    args.with_defaults(:source_id => :none, :mode => :new)
    cities = City.all.to_a

    progressbar = ProgressBar.create(:format => '%a %B %p%% %t %c/%C', :starting_at => 0, :total => cities.count)
    cities.each do |city|
      tenders = Tender
      tenders = Tender.where(source_id: args.source_id) unless args.source_id.to_sym == :none
      tenders = tenders.any_of({:customer_address => /(^|.*[^а-я])#{city.name}([^а-я].*|$)/i})

      case args.mode.to_sym
        when :indefinite
          tenders = tenders.where(city_code: -1).to_a
        when :all
          tenders = tenders.to_a
        else
          tenders = tenders.where(city_code: nil).to_a
      end

      tenders.each do |tender|
        tender.city_code = city.city_code
        tender.save
      end

      progressbar.increment
    end
  end

  ################ SET REGION AND CITY CODES FOR TENDERS ################

  desc "Set cities and regions for tenders by yandex"
  task :yandex_updater do
    tenders = Tender.where(:external_work_type.gt => 0, region_code: nil).order_by(created_at: :desc).to_a
    progressbar = ProgressBar.create(:format => '%a %B %p%% %t %c/%C', :starting_at => 0, :total => tenders.count)
    tenders.each do |t|
      address_processor = AddressProcessor.new(t.customer_address)
      codes = address_processor.process
      t.region_code = codes[:region_code]
      t.city_code = codes[:city_code]
      t.save
      progressbar.increment
    end
  end

  desc "[REVERSE VERSION] Set regions for tenders; source_id=none for all tenders; modes: new(region code is null, default), indefinite(region code equally -1), all"
  task :set_region_and_city_codes_for_tender_reverse, :source_id, :mode do |t, args|
    args.with_defaults(:source_id => :none, :mode => :new)

    regions = Region.all.to_a
    progressbar = ProgressBar.create(:format => '%a %B %p%% %t %c/%C', :starting_at => 0, :total => regions.count)

    regions.each do |region|
      tenders = Tender
      tenders = tenders.where(source_id: args.source_id) unless args.source_id == :none
      tenders = tenders.any_of({:customer_address => /(^|.*[^а-я])#{region.name}([^а-я].*|$)/i})

      case args.mode.to_sym
        when :indefinite
          tenders = tenders.where(region_code: -1).to_a
        when :all
          tenders = tenders.to_a
        else
          tenders = tenders.where(region_code: nil).to_a
      end

      cities = City.where(region_code: region.region_code).to_a

      tenders.each do |tender|
        cities.each do |city|
          unless /(^|.*[^а-я])#{city.name}([^а-я].*|$)/i.match(tender.customer_address).to_s.empty?
            tender.city_code = city.city_code
            break
          end
        end

        tender.region_code = region.region_code
        tender.save
      end

      progressbar.increment
    end
  end

  desc "Set cities and regions for tenders"
  task :set_cities_and_regions_in_tenders, :source_id, :city_mode, :region_mode do |t, args|
    args.with_defaults(:source_id => nil, :city_mode => :on, :region_mode => :on)

    city_mode = args[:city_mode].to_sym
    region_mode = args[:region_mode].to_sym

    mode_filter = []
    unless city_mode == :off
      mode_filter.push({:city_code => nil})
      cities = City.all.to_a
    end
    unless region_mode == :off
      mode_filter.push({:region_code => nil})
      regions = Region.all.to_a
    end

    abort("No mode") if mode_filter.empty?

    tenders = Tender.where(:customer_address.ne => nil)
    tenders = tenders.where(:source_id => args[:source_id]) unless args[:source_id].nil? || args[:source_id].empty?
    tenders = tenders.or(mode_filter)

    tenders.each do |t|
      unless region_mode == :off
        regions.each do |r|
          if t.customer_address.include? r.name
            t.region_code = r.region_code
            break
          end
        end
      end

      unless city_mode == :off

        unless t.region_code.to_i > 0
          t.city_code = DEFAULT_CITY_CODE
        end

        last_region_code = DEFAULT_REGION_CODE

        cities.each do |c|
          if t.customer_address.include? c.name
            t.city_code = c.city_code
            last_region_code = c.region_code
            break
          end
        end

        if t.city_code > 0 && t.region_code.to_i < 1
          t.region_code = last_region_code
        end
      end
      t.save
    end
  end
end

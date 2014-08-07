# Rake file for dev/test rake tasks
namespace :dev do
  desc "Clear tendetrs from cities and regions"
  task :clear_tenders_from_cities_and_regions do
    Tender.all.each do |t|
      t.external_city_id = nil
      t.external_region_id = nil
      t.save
    end
  end

  task :show_cities do
    total = 0
    City.all.each do |c|
      if c.name.length <= 3
        p c.name
        total += 1
      end
    end

    p "Total: " + total.to_s
  end

  desc "Update cities collection from mysql"
  task :update_cities_from_mysql do
    puts "Deleting all documents from collection"
    City.delete_all

    puts "Load cities from mysql"
    query = "SELECT c.id, c.name, d.`id_region` FROM `altasib_kladr_cities` c LEFT JOIN `altasib_kladr_districts` d ON c.`ID_DISTRICT` = d.`CODE`"
    records = ActiveRecord::Base.connection.exec_query(query)

    progressbar = ProgressBar.create(:title => "Progress", :starting_at => 0, :total => records.count)
    records.each do |record|
      city = City.new
      city.external_id = record["id"].to_i
      city.name = record["name"]
      city.region_id = record["id_region"].to_i
      city.save

      progressbar.increment
    end
  end

  task :test_address_processor do
    address_processor = AddressProcessor.new

    Tender.skip(100).limit(10).each do |t|
      puts '*'*30
      #puts address_processor.process(t.customer_address)
      puts '*'*30
    end
  end

  task :show_selector do
    Grappler.new(Selector.find('538c67e690c043fa4d00000b'), '1858403').grapple
  end
end
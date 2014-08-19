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
    City.where({:region_code => 0}).each do |c|
      puts "#{c.name}: "
      total += 1
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

    progress_bar = ProgressBar.create(:title => "Progress", :starting_at => 0, :total => records.count)
    records.each do |record|
      city = City.new
      city.external_id = record["id"].to_i
      city.name = record["name"]
      city.region_id = record["id_region"].to_i
      city.save

      progress_bar.increment
    end
  end

  task :test_address_processor do
    tenders = Tender.where(:external_work_type.gt => 0, city_code: nil).limit(10000).order_by(created_at: :desc).to_a
    progressbar = ProgressBar.create(:format => '%a %B %p%% %t %c/%C', :starting_at => 0, :total => tenders.count)
    tenders.each do |t|
      address_processor = AddressProcessor.new(t.customer_address)
      codes = address_processor.process
      t.region_code = codes[:region_code]
      t.city_code = codes[:city_code]
      t.save
      progressbar.increment
      #puts "-"*20
    end
  end

  task :test_progressbar do
    progressbar = ProgressBar.create(:format => '%a %B %p%% %t %c / %C', :starting_at => 0, :total => 30)
    i = 0
    while i < 30 do
      progressbar.increment
      sleep 1
      i += 1
    end
  end

  task :show_selector do
    Grappler.new(Selector.find('538c67e690c043fa4d00000b'), '1858403').grapple
  end
end
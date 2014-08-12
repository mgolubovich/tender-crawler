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

  task :test_address_processor do
    Tender.skip(100).limit(1000).each do |t|
      address_processor = AddressProcessor.new(t.customer_address)
      puts address_processor.process
      puts "-"*20
    end
  end

  task :show_selector do
    Grappler.new(Selector.find('538c67e690c043fa4d00000b'), '1858403').grapple
  end
end
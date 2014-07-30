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
end
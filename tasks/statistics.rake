namespace :statistics do
  desc "Update statistics"
  task :update_statistic_for, :source_id do |t, args|
    source = Source.find args.source_id
    source.tenders_count = source.tenders.count
    source.save
    puts "[#{Time.now}] Statistic tenders count for #{source.name} updated to #{source.tenders_count}"
  end
  task :update_global_statistics do
    stat = Statistics.first
    stat.global_sources_count = Source.count
    stat.global_cartridges_count = Cartridge.count
    stat.global_selectors_count = Selector.count
    stat.global_tenders_count = Tender.count
    stat.global_rules_count = Rule.count
    stat.global_page_managers_count = PageManager.count
    stat.global_cities_count = City.count
    stat.global_regions_count = Region.count
    puts "[#{Time.now}] Source: #{stat.global_sources_count}, Cart: #{stat.global_cartridges_count}, Selector: #{stat.global_selectors_count}, etc..."
    stat.save
  end
  task :update_all => :update_global_statistics do
    Source.each do |source|
     source.tenders_count = source.tenders.count
     source.save
     puts "[#{Time.now}] Statistic tenders count for #{source.name} updated to #{source.tenders_count}"
    end
  end
end

namespace :statistics do

  desc 'Update statistics for source'
  task :update_statistic_for, :source_id do |_t, args|
    source = Source.find args.source_id
    source.tenders_count = source.tenders.count
    source.construction_tenders_count = source.tenders.where(:external_work_type.gt => 1).count
    source.save
    puts "[#{Time.now}] Statistic tenders count for #{source.name} updated to #{source.tenders_count}"
  end

  desc 'Update global statistics'
  task :update_global_statistics do
    stat = Statistics.last
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

  desc 'Update moderated tenders today'
  task :update_moderated_today do
    stat = Statistics.last
    stat.moderation_today_count = Tender.where(:moderated_at.gte => Time.now.at_beginning_of_day).count
    stat.save
    puts "[#{Time.now}] Moderated today: #{stat.moderation_today_count}"
  end

  desc 'Update all statistics'
  task update_all: [:update_global_statistics, :update_moderation_today] do
    Source.each do |source|
      source.tenders_count = source.tenders.count
      source.construction_tenders_count = source.tenders.where(:external_work_type.gt => 1).count
      source.save
      puts "[#{Time.now}] Statistic tenders count for #{source.name} updated to #{source.tenders_count} [#{source.construction_tenders_count}]"
    end
  end

  desc 'Reset yandex counter'
  task :reset_yandex_counter do
    stat = Statistics.last
    stat.reset_yandex_counter
  end

end

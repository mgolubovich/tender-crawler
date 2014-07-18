# Rake file for storing parsing rake tasks
namespace :parsing do
  
  desc "Test task for reaping zakupki"
  task :test_reap do
    Reaper.new(Source.first, 500).reap
  end

  desc "Reap for a specific source"
  task :reap, :source_id, :deep_level do |t, args|
    Reaper.new(Source.find(args.source_id), {:limit => args.deep_level.to_i}).reap
  end

  desc "Task for testing single selector"
  task :test_grapple, :selector_id, :entity_id do |t, args|
    selector = Selector.find(args.selector_id)
    result = Hash.new
    entity_id = args.entity_id.length > 0 ? args.entity_id : ''
    
    result[:grappled_value] = selector.value_type == :ids_set ? Grappler.new(selector, entity_id).grapple_all : Grappler.new(selector, entity_id).grapple
    result[:selector_type] = selector.value_type
    
    puts result.to_json
  end

  desc "Task for getting new tenders"
  task :reap_all do
    sources = Source.active
    source.each do |s|
      reaper = Reaper.new s
      reaper.reap
    end
  end

  desc "Update all tenders task"
  task :reap_update_all_for, :source_id do |t, args|
    ids_set = []
    source = Source.find(args.source_id)
    source.tenders.each {|t| ids_set << t.id_by_source}

    Reaper.new(source).reap(ids_set)
  end

  desc "Set regions for tenders"
  task :set_regions_in_tenders_for, :source_id do |t, args|
    source = Source.find(args.source_id)
    tenders = source.tenders.where(:customer_address.ne => nil).where(:external_region_id => nil)
    regions = Region.all

    tenders.each do |t|
        regions.each do |r|
          t.external_region_id = r.external_id if t.customer_address.include? r.name
        end
        t.save
    end
  end

  desc 'Set cities for tenders'
  task :set_cities_in_tenders_for, :source_id do |t, args|
    tenders = Source.find(args.source_id).tenders.where(:customer_address.ne => nil).where(:external_city_id => nil)
    cities = City.all

    tenders.each do |t|
      cities.each do |c|
          t.external_city_id = c.external_id if t.customer_address.include? c.name
      end
      t.save
    end
  end
end
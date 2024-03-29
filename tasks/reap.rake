# Rake file for storing parsing rake tasks
namespace :parsing do

  desc 'Test task for reaping zakupki'
  task :test_reap do
    Reaper.new(Source.first, {:limit => 10}).reap
  end

  desc 'Reap for a specific source'
  task :reap, :source_id, :deep_level do |t, args|
    Reaper.new(Source.find(args.source_id), {:limit => args.deep_level.to_i}).reap
  end

  desc 'Task for testing single selector'
  task :test_grapple, :selector_id, :entity_id do |t, args|
    selector = Selector.find(args.selector_id)
    result = Hash.new
    entity_id = args.entity_id.length > 0 ? args.entity_id : ''

    result[:selector_type] = selector.value_type
    result[:grappled_value] = selector.value_type?(:ids_set) ? Grappler.new(selector, entity_id).grapple_all : Grappler.new(selector, entity_id).grapple

    puts result.to_json
  end

  desc 'Task for getting new tenders'
  task :reap_all do
    sources = Source.active
    sources.each do |s|
      reaper = Reaper.new(s, { :limit => s.deep_level })
      reaper.reap
    end
  end
end

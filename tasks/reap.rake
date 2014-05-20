# Rake file for storing parsing rake tasks
namespace :parsing do
  
  desc "Test task for reaping zakupki"
  task :test_reap do
    Reaper.new(Source.first).reap
  end

  desc "Reap for a specific source"
  task :reap, :source_id, :deep_level do |t, args|
    Reaper.new(Source.find(args.source_id), args.deep_level.to_i).reap
  end

  desc "Task for testing single selector"
  task :test_grapple do
    selector = Source.active.where(:name => 'zakupki.gov.ru').first.selectors.where(:value_type => :code_by_source).first
    hook = Grappler.new 
    hook.charge(selector, '8334313')
    puts hook.grapple
  end

  desc "Task for getting new tenders"
  task :reap_all do
    sources = Source.active
    source.each do |s|
      reaper = Reaper.new s
      reaper.reap
    end
  end
end
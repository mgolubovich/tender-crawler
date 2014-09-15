# Rake file for dev/test rake tasks
require 'ruby-prof'
namespace :dev do
  desc "Clear tendetrs from cities and regions"
  task :clear_tenders_from_cities_and_regions do
    Tender.all.each do |t|
      t.region_code = nil
      t.city_code = nil
      t.save
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

  task :test_wt_proc do
    puts WorkTypeProcessor.new([{:code=>"45.31.41.110", :title=>"45.31.41.110"}]).process
  end

  task :measure do
    RubyProf.start
    Reaper.new(Source.first, {:limit => 100}).reap
    result = RubyProf.stop

    printer = RubyProf::FlatPrinter.new(result)
    printer.print(File.open('tmp/profile.txt', 'w'))
  end
end

# Rake file for storing parsing rake tasks
namespace :parsing do
  
  desc "Test task for reaping zakupki"
  task :test_reap do
    reaper = Reaper.new(Source.active.first)
    reaper.reap
    puts reaper.result
  end

  desc "Task for testing single selector"
  task :test_grapple do

  end
end
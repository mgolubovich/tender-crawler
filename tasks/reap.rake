desc "Test task for reaping zakupki"
task :check_write_permissions => :enviroment do
  reaper = Reaper.new(Source.active.first)
  reaper.reap
  puts reaper.result
end
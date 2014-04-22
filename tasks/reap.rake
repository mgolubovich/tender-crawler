desc "Test task for reaping zakupki"
task :test_reap do
  reaper = Reaper.new(Source.active.first)
  reaper.reap
  puts reaper.result
end
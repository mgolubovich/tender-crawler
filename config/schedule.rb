# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
every 5.minutes do
  rake 'statistics:update_all'
end

every 50.minutes do
  rake 'address:set_region_code_for_tender_reverse'
end

every 53.minutes do
  rake 'address:set_region_code_for_tenders_by_postcode'
end

every 55.minutes do
  rake 'address:yandex_updater'
end

every 12.hours do
  rake 'utils:load_proxies'
end

every :day, at: '12:05am' do
  rake 'statistics:reset_yandex_counter'
end

every 56.minutes do
  rake 'parsing:protocols:zakupki[500]'
end

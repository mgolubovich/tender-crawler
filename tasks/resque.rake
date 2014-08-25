require 'resque/tasks'
require 'resque_scheduler/tasks'

task "resque/setup" => :environment do
  Resque::Scheduler.dynamic = true
  ENV['QUEUE'] = '*'
end

namespace :resque do

  task :auto_reap do
    Resque.clean_schedules

    priorities = YAML.load_file('config/dictionaries/resque_priorities.yml').symbolize_keys!
    priorities.each_key { |queue| Resque.remove_queue(queue) if priorities[queue]["type"].to_sym == :auto }

    params = {
        :resque_frequency.gt => 0,
        :is_active => true
    }

    Source.where(params).to_a.each do |source|
      config = {
          every: "#{source.resque_frequency}m",
          class: "ReapJob",
          args: [source._id, source.deep_level],
          queue: source.priority
      }

      Resque.set_schedule("reap_#{source._id}", config)
    end
  end


  task :manual_reap, :source_id, :deep_level do |t, args|
    Resque.enqueue( ReapJob, args.source_id, args.deep_level )
  end
end
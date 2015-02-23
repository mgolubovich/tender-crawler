namespace :utils do
  desc "Task for converting selectors offset field from old one digit format to new hash-like"
  task :convert_offset_for_selectors do
    selectors = Selector.all
    selectors.each do |selector|
      unless selector.offset.kind_of? Hash
        selector.offset = { "start" => 0, "end" => selector.offset }
        selector.save
      end
    end
  end

  desc 'Export schedule.rb to crontab'
  task :export_tasks_to_crontab do
    %x(whenever -w)
  end

  desc 'Load proxies from hide.me'
  task :load_proxies do
    Proxy.delete_all

    hm_config = YAML.load_file('config/best_proxy_params.yml')
    hm_url = hm_config['base_url'] + hm_config.map { |k, v| "#{k}=#{v}" unless k == 'base_url'}.join('&')
    raw_data = open(hm_url).read
    data = raw_data.split("\n").map do |val|
      split_adress = val.split(':')
      { host:split_adress[0], port: split_adress[1], delay:0 }
    end

    progress_bar = ProgressBar.create(
      title: 'Inserting new proxies',
      starting_at: 0,
      total: data.count
      )

    data.each do |p|
      Proxy.create(address: p[:host], port: p[:port], latency: p[:delay])
      progress_bar.increment
    end
  end

  desc 'Setting external_work_type for tenders with ewt = 0'
  task :set_external_work_type do
    tenders = Tender.where(external_work_type: 0)

    progress_bar = ProgressBar.create(
      title: 'Processing tenders',
      format: '%a %B %p%% %t %c/%C',
      starting_at: 0,
      total: tenders.count
      )

    tenders.each do |t|
      t.external_work_type = WorkTypeProcessor.new(t.work_type).process
      t.save
      progress_bar.increment
    end
  end
end
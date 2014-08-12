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
    hm_config = YAML.load_file('config/hideme_params.yml')
    hm_url = hm_config['base_url'] + hm_config.map { |k, v| "#{k}=#{v}" unless k == 'base_url'}.join('&')

    raw_data = open(hm_url).read
    data = JSON.parse(raw_data)

    data.each do |p|
      Proxy.create(address: p['host'], port: p['port'], latency: p['delay'])
    end
  end
end
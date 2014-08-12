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
    raw_data = open('http://hideme.ru/api/proxylist.php?out=js&country=RU&maxtime=500&code=1565406105').read
    data = JSON.parse(raw_data)

    data.each do |p|
      
    end
  end
end
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
end
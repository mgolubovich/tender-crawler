# Class used for processing and parsing date from strings
class DateProcessor
  @dictionary = YAML.load_file('config/dictionaries/russian_dates_dict.yml')

  def initialize(raw_data, format = nil)
    @raw_data = raw_data
    @format = format
  end

  def process
    @format.slice!('[RUSSIAN]') && transliterate
    parse
  end

  private

  def parse
    @date = @format ? DateTime.strptime(@raw_data, @format) : DateTime.parse(@raw_data)
    @date = @date.change(offset: '+0400') if @date.offset == (0 / 1)
    @date.to_time
  rescue ArgumentError
    nil
  end

  def transliterate
    DateProcessor.dictionary.each do |month, word|
      @raw_data.gsub!(word, "|#{month}|")
    end
  end
end

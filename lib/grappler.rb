# Grappler is entity used for parsing
# single or multiple values of same value_type
class Grappler
  def load(selector)
    @selector = selector
    @log = ParserLog.new.logger
    @log.set_source(selector.source_id)
    self
  end

  def grapple(mode = :single)
    @mode = [:single, :multiple].include?(mode) ? mode : :single
    target_data = []

    Capybara.execute_script(@selector.js_code)

    page = Capybara::HTML(Capybara.page.body)

    slice = page.send(@selector.path_type, @selector.path)
    slice.each do |item|
      target_data << process(item) unless @selector.can_be_empty? && item.text.strip.empty?
    end

    @mode == :single ? target_data.first : target_data
  end

  def grapple_all
    grapple(:multiple)
  end

  private

  def process(item)
    data = get_raw_data(item)
    return data if data.nil?

    data.strip!

    return '' if data.empty?
    data = apply_offset(data) if @selector.offset_valid?
    data = apply_regexp(data) if @selector.regexp_valid?
    data = apply_date_format(data) if @selector.field_valid?(:date_format)
    data = apply_to_type(data) if @selector.field_valid?(:to_type)

    data
  end

  def get_raw_data(item)
    return item[@selector.attr.to_sym] if @selector.field_valid?(:attr)
    return item.text unless @selector.field_valid?(:delimiter)
    item.css('*').map { |c| c.text }.join(@selector.delimiter)
  rescue Capybara::Poltergeist::ObsoleteNode
    screen = Capybara.page.driver.render_base64
    @log.error('Obsolete Node', selector: @selector, screen: screen)
    return ''
  end

  def apply_offset(data)
    data[@selector.offset['start']..@selector.offset['end']]
  end

  def apply_regexp(data)
    pattern = Regexp.new(@selector.regexp['pattern'])
    return data.gsub(pattern, '') if @selector.regexp_mode?(:gsub)
    data.scan(pattern).join
  end

  def apply_date_format(data)
    DateProcessor.new(data, @selector.date_format).process
  end

  def apply_to_type(data)
    case @selector.to_type
      when :float
        data.gsub(',', '.').gsub(' ', '').to_f
      when :integer
        data.to_i
      when :symbol
        data.to_sym
      else
        data
    end
  end
end

# Grappler is entity used for parsing
# single or multiple values of same value_type
class Grappler
  Capybara.default_driver = :webkit
  Capybara.run_server = false
  Capybara.default_wait_time = 5

  def initialize(selector, entity_id = '')
    @selector = selector
    @link = selector.link_template.gsub('$entity_id', entity_id.to_s)
  end

  def grapple(mode = :single)
    @mode = [:single, :multiple].include?(mode) ? mode : :single
    target_data = []

    Capybara.execute_script(@selector.js_code)

    selecting_type = @selector.field_valid?(:css) ? :css : :xpath
    slice = Capybara.all(selecting_type, @selector[selecting_type])

    slice.each { |item| target_data << process(item) }

    @mode == :single ? target_data.first : target_data
  end

  def grapple_all
    grapple(:multiple)
  end

  private

  def process(item)
    data = get_raw_data(item)
    data.strip

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
    item.all(:css, '*').map { |c| c.text }.join(@selector.delimiter)
  end

  def apply_offset(data)
    return data unless @selector.offset_valid?
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

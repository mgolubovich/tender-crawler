# Grappler is entity used for parsing
# single or multiple values of same value_type
class Grappler
  include Capybara::DSL
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

    # Fix later, need to cut web-navigation from grappler
    if @selector.value_type != :ids_set
      visit @link unless current_url == @link
    end

    execute_script(@selector.js_code) unless @selector.js_code.nil?

    slice = @selector.css.empty? ? all(:xpath, @selector.xpath) : all(:css, @selector.css)
    slice.each do |item|
      data = @selector.attr.empty? ? item.text.strip : item[@selector.attr.to_sym].strip
      data = apply_offset(data) unless @selector.offset.nil? || data.empty?
      data = apply_regexp(data) unless @selector.regexp["pattern"].empty? || data.to_s.empty?
      data = apply_date_format(data) unless @selector.date_format.to_s.empty? || data.to_s.empty?
      data = apply_to_type(data) unless @selector.to_type.nil? || data.to_s.empty?
      target_data << data
    end

    @mode == :single ? target_data.first : target_data
  end

  def grapple_all
    grapple :multiple
  end

  private

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
      data.gsub!(',', '.').to_f
    when :integer
      data = data.to_i
    when :symbol
      data = data.to_sym
    else
      data
    end
  end
end

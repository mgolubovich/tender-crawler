require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'
require 'date'
#require 'debugger'

class Grappler

  include Capybara::DSL
  Capybara.default_driver = :webkit
  Capybara.run_server = false
  Capybara.default_wait_time = 5

  def initialize(selector, entity_id='')
    @value_type = selector.value_type.to_sym
    @link = selector.link_template.gsub('$entity_id', entity_id.to_s)
    @xpath = selector.xpath.to_s
    @css = selector.css.to_s
    @attr = selector.attr.to_s unless selector.attr.nil?
    @offset = selector.offset unless selector.offset.nil?
    @regexp = selector.regexp unless selector.regexp.nil?
    @date_format = selector.date_format.to_s unless selector.date_format.nil?
    @js_code = selector.js_code unless selector.js_code.nil?
    @to_type = selector.to_type unless selector.to_type.nil? || selector.to_type.empty?
  end

  def grapple(mode = :single)
    @mode = [:single, :multiple].include?(mode) ? mode : :single
    target_data = []

    if @value_type != :ids_set
      visit @link unless current_url == @link
    end
    
    # ParserLog.logger.info("Visit - #{@link}")

    execute_script(@js_code) unless @js_code.nil?

    slice = @css.empty? ? all(:xpath, @xpath) : all(:css, @css)

    slice.each do |item|
      #debugger
      data = @attr.empty? ? item.text.to_s.strip : item[@attr.to_sym].to_s.strip
      data = apply_offset(data) unless @offset.nil? || data.empty?
      data = apply_regexp(data) unless @regexp["pattern"].empty? || data.empty?
      data = apply_date_format(data) unless @date_format.empty? || data.empty?
      data = apply_to_type(data) unless @to_type.nil? || data.to_s.empty? || @to_type.empty?
      target_data << data
    end

    @mode == :single ? target_data.first : target_data
  end

  def grapple_all
    grapple :multiple
  end

  private

  def apply_offset(data) 
    data = data[@offset["start"]..@offset["end"]] if @offset["start"] != 0 && @offset["end"] != 0
    data
  end

  def apply_regexp(data)
    @regexp["mode"] == "gsub" ? data.gsub!(Regexp.new(@regexp["pattern"]), '') : data.scan(Regexp.new(@regexp["pattern"])).join
  end

  def apply_date_format(data)
    begin
      DateTime.parse(data, @date_format).to_time
    rescue Exception
      nil
    end
  end

  def apply_to_type(data)
    case @to_type
      when :float
        data.gsub!(',','.')
        data = data.to_f
      when :integer
        data = data.to_i
      when :symbol
        data = data.to_sym
      when :string
      else
        data
    end
    data
  end

end
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'
require 'date'

class Grappler

  include Capybara::DSL
  Capybara.default_driver = :webkit
  Capybara.run_server = false
  Capybara.default_wait_time = 5

  def initialize(selector, entity_id='')
    @selector = selector
    @link = selector.link_template.gsub('$entity_id', entity_id.to_s)
  end

  def grapple(mode = :single)
    @mode = [:single, :multiple].include?(mode) ? mode : :single
    target_data = []

    if @selector.value_type != :ids_set
      visit @link unless current_url == @link
    end
    
    # ParserLog.logger.info("Visit - #{@link}")

    execute_script(@selector.js_code) unless @selector.js_code.nil?

    slice = @selector.css.empty? ? all(:xpath, @selector.xpath) : all(:css, @selector.css)
    
    slice.each do |item|
      data = @selector.attr.empty? ? item.text.to_s.strip : item[@selector.attr.to_sym].to_s.strip
      data = apply_offset(data) unless @selector.offset.nil? || data.empty?
      data = apply_regexp(data) unless @selector.regexp["pattern"].empty? || data.to_s.empty?
      data = apply_date_format(data) unless @selector.date_format.to_s.empty? || data.to_s.empty?
      data = apply_to_type(data) unless @selector.to_type.nil? || data.to_s.empty? || @selector.to_type.empty?
      target_data << data
    end

    @mode == :single ? target_data.first : target_data
  end

  def grapple_all
    grapple :multiple
  end

  private

  def apply_offset(data) 
    data = data[@selector.offset["start"]..@selector.offset["end"]] if @selector.offset["start"] != 0 && @selector.offset["end"] != 0
    data
  end

  def apply_regexp(data)
    @selector.regexp["mode"] == "gsub" ? data.gsub!(Regexp.new(@selector.regexp["pattern"]), '') : data.scan(Regexp.new(@selector.regexp["pattern"])).join
  end

  def apply_date_format(data)
    begin
      data = DateTime.parse(data, @selector.date_format)
      data = data.change(:offset => "+0400") if data.offset == (0/1)
      data.to_time
    rescue Exception
      nil
    end
  end

  def apply_to_type(data)
    case @selector.to_type
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
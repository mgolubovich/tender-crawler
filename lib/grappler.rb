require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'
require 'date'
#require 'debugger'

class Grappler

  include Capybara::DSL
  Capybara.default_driver = :webkit
  Capybara.run_server = false

  def initialize(selector, entity_id='')
    @link = selector.link_template.gsub('$entity_id', entity_id)
    @xpath = selector.xpath
    @css = selector.css
    @attr = selector.attr unless selector.attr.nil?
    @offset = selector.offset unless selector.offset.nil?
    @regexp = selector.regexp unless selector.regexp.nil?
    @date_format = selector.date_format unless selector.date_format.nil?
    @js_code = selector.js_code unless selector.js_code.nil?
  end

  def grapple(mode = :single)
    @mode = [:single, :multiple].include?(mode) ? mode : :single
    target_data = []

    visit @link
    ParserLog.logger.info("Visit - #{@link}")

    execute_script(@js_code) unless @js_code.nil?

    slice = @css.empty? ? all(:xpath, @xpath) : all(:css, @css)
    puts "#{slice} - #{slice.size} - #{slice.first}"
    slice.each do |item|
      data = @attr.empty? ? item.text.to_s.strip : item[@attr.to_sym].to_s.strip
      puts data
      data = apply_offset(data) unless @offset.nil? || data.empty?
      puts "Data after offset #{data}"
      data = apply_regexp(data) unless @regexp.empty? || data.empty?
      puts "Data after regexp #{data}"
      data = apply_date_format(data) unless @date_format.empty? || data.empty?
      target_data << data
    end

    @mode == :single ? target_data.first : target_data
  end

  def grapple_all
    grapple :multiple
  end

  private

  def apply_offset(data)
    if @offset.to_i > 0
       data = data[0..@offset.to_i]
    elsif @offset.to_i < 0
      data = data[@offset.to_i, @offset.to_i.abs]
    end
    puts "Data in offset #{data}"
    data
  end

  def apply_regexp(data)
    data.gsub!(Regexp.new(@regexp), '')
  end

  def apply_date_format(data)
    begin
      DateTime.parse(data, @date_format)
    rescue ArgumentError
      nil
    end
  end

end
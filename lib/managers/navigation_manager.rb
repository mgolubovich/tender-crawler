# Class that handles web-navigation
class NavigationManager
  class << self
    attr_accessor :accepted_codes
  end

  @accepted_codes = [202]

  def initialize
    @proxy_manager = ProxyManager.new
    @is_proxified = false
  end

  def load(pm)
    @pm = pm
    @current_page = @pm.page_number_start_value
    @list_link = @pm.cartridge.base_list_template
    @is_started = false
  end

  def go(url, reload = false)
    return if (url == location) && !reload
    Capybara.visit(url)
    ParserLog.logger.info "[#{Time.now}] - visited #{url}"
  rescue Capybara::Webkit::InvalidResponseError => ex
    return if status_code?
    puts ex.message
    save_the_day
    go(url, true)
  end

  def next_page
    @current_page += 1
    case @pm.action_type
    when :get
      go(@list_link.gsub('$page_number', next_page_number))
    when :click
      initial_visit unless @is_started
      Capybara.find(:xpath, @pm.action_value).click
    when :js
      initial_visit unless @is_started
      Capybara.execute_script(@pm.action_value.gsub('$page_number', next_page_number))
    end
    sleep @pm.delay_between_pages
  end

  private

  def location
    Capybara.current_url
  end

  def initial_visit
    go(@list_link.gsub('$page_number', @pm.page_number_start_value.to_s))
    @is_started = true
  end

  def next_page_number
    return "0#{@current_page}" if @pm.leading_zero && @current_page < 10
    "#{@current_page}"
  end

  def status_code?
    NavigationManager.accepted_codes.include?(Capybara.page.status_code) ? true : false
  end

  def save_the_day
    if @proxy_manager.proxies_left?
      @is_proxified = true
      @proxy_manager.switch_proxy
    else
      fail(ConnectionError, 'Used all proxies', caller)
    end
  end
end

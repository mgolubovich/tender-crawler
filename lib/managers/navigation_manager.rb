require 'digest/md5'

# Class that handles web-navigation
class NavigationManager
  class << self
    attr_accessor :accepted_codes
  end

  @accepted_codes = %w(202)

  def initialize
    @is_proxified = false
    @attempts_count = 0
    @log = ParserLog.new.logger
  end

  def load(pm)
    @pm = pm
    @current_page = @pm.page_number_start_value
    @list_link = @pm.cartridge.base_list_template
    @is_started = false
    source_id = Cartridge.find(@pm.cartridge_id).source_id
    @log.set_source(source_id)
    @proxy_manager = ProxyManager.new(source_id)
  end

  def go(url, reload = false, use_proxy=true)
    return true if (url == location) && !reload
    @log.info('visit', url: url)
    Capybara.visit(url)
    if @pm
      if @pm.cartridge.need_to_sleep?
        @log.info('sleep', sleep_time: @pm.cartridge.delay_between_tenders)
        sleep(@pm.cartridge.delay_between_tenders)
      end
    end
    return true
  rescue Capybara::Poltergeist::TimeoutError => ex
    #return if status_code?
    puts ex.message
    @log.error(ex.message, trace: ex.backtrace, url: url, reload: reload)
    if use_proxy
      @proxy_manager.save_the_day
      go(url, true)
    else
      return nil
    end

  end

  def next_page
    begin
      @current_page += 1
      case @pm.action_type
        when :get
          @log.info('go', pm: @pm, next_page_number: next_page_number)
          go(@list_link.gsub('$page_number', next_page_number))
        when :click
          initial_visit unless @is_started
          @log.info('click', pm: @pm)
          click_on(@pm.action_value)
        when :js
          if @is_started
            @log.info('script', pm: @pm, next_page_number: next_page_number)
            Capybara.execute_script(@pm.action_value.gsub('$page_number', next_page_number))
          else
            initial_visit
          end
      end
    rescue Capybara::ElementNotFound
      screen = Capybara.page.driver.render_base64
      @log.error('element not found', pm: @pm, screen: screen)
      return
    rescue Capybara::Poltergeist::ObsoleteNode
      screen = Capybara.page.driver.render_base64
      @log.error('Obsolete node', pm: @pm, screen: screen)
      return
    rescue Capybara::Poltergeist::TimeoutError
      @log.error('click timeout error', pm: @pm)
      save_the_day
      return
    rescue Capybara::CapybaraError
      screen = Capybara.page.driver.render_base64
      @log.error('capybara error', location: location, screen: screen)
      fail(ConnectionError, 'Problems with remote server', caller) if @attempts_count > 6
    ensure
      @log.info('sleep', sleep_time: @pm.delay_between_pages)
      sleep(@pm.delay_between_pages)
    end
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

  def click_on(xpath)
    Capybara.find(:xpath, xpath).trigger('click')
  end

  def page_ready?
  end
end

# Class for proxy checking, using
# changing and so on
class ProxyManager
  def initialize(source_id)
    #ap @proxies
    @log = ParserLog.new.logger
    @log.set_source(source_id)
    @semaphore = Mutex.new
    @source_id = source_id
    refresh_proxy_list
    @current_proxy = nil
  end

  def refresh_proxy_list
    @proxies = Proxy.where(:rejected_sources.nin=>[@source_id] ).order_by(latency: :desc).limit(100).to_a
  end

  def switch_proxy
    proxy = next_proxy
    @log.info('use proxy', proxy: proxy)
    refresh_driver("polter_#{proxy[:host]}_#{proxy[:port]}",
                   ["--proxy=#{proxy[:host]}:#{proxy[:port]}"])
  end

  def reset_proxy
    @log.info('reset proxy')
    refresh_driver('polter_no_proxy')
  end

  def proxies_left?
    @proxies.count > 0 ? true : false
  end

  def save_the_day
    @semaphore.synchronize do
      if proxies_left?
        # Capybara.page.driver.reset!
        # Capybara.page.driver.quit
        switch_proxy
        return true
      else
        @log.error('Used all proxies')
        return false
      end
    end
  end

  def current_proxy
    @current_proxy
  end

  def reject_current_proxy
    @current_proxy.push(rejected_sources:@source_id)
    @current_proxy.save!
  end

  private

  def next_proxy
    proxy = @proxies.pop
    @log.info('reject proxy', proxy: @current_proxy)
    reject_current_proxy unless @current_proxy.nil?
    @current_proxy = proxy
    { host: proxy.address, port: proxy.port }
  end

  def no_proxy
    { host: '', port: '' }
  end

  def refresh_driver(driver_name, opts = [])
    driver_name = driver_name.to_sym

    sleep(0.5)
    #Capybara.reset_sessions!

    Capybara.register_driver driver_name do |app|
      Capybara::Poltergeist::Driver.new(
          app,
          js_errors: false,
          phantomjs_options: ["--load-images=no", "--ignore-ssl-errors=yes"] + opts,
          timeout: 20,
          debug: false)
    end
    Capybara.current_driver = driver_name
    #Capybara.page.driver.restart
    @log.info('set driver', driver: driver_name)
  end

end

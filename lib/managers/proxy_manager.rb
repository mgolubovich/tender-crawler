# Class for proxy checking, using
# changing and so on
class ProxyManager
  def initialize
    @proxies = Proxy.all.order_by(latency: :desc).to_a
  end

  def switch_proxy
    Capybara.page.driver.browser.set_proxy(next_proxy)
  end

  def reset_proxy
  end

  private

  def next_proxy
    proxy = @proxies.pop
    { host: proxy.address, port: proxy.port }
  end
end

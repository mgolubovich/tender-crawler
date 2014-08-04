class Reaper
  # Service-class, manages pagination
  class PaginationObserver
    include Capybara::DSL
    Capybara.default_driver = :webkit
    Capybara.run_server = false

    attr_accessor :current_page, :initial_visit, :pm

    def initialize(page_manager)
      @pm = page_manager
      @current_page = page_manager.page_number_start_value
      @is_started = false
    end

    def next_page
      @current_page += 1
      case @pm.action_type
      when :get
        next_page = @pm.cartridge.base_list_template.gsub('$page_number', next_page_number)
        visit next_page
      when :click
        initial_visit unless @is_started
        find(:xpath, @pm.action_value).click
      when :js
        initial_visit unless @is_started
        execute_script(@pm.action_value.gsub!('$page_number', next_page_number))
      end
      sleep @pm.delay_between_pages
    end

    private

    def initial_visit
      initial_page = @pm.cartridge.base_list_template.gsub('$page_number', @pm.page_number_start_value.to_s)
      visit initial_page
      @is_started = true
    end

    def next_page_number
      return "0#{@current_page}" if @pm.leading_zero && @current_page < 10
      "#{@current_page}"
    end
  end
end

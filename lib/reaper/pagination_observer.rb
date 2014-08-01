class Reaper
  # Service-class, manages pagination
  class PaginationObserver
    include Capybara::DSL
    Capybara.default_driver = :webkit
    Capybara.run_server = false

    attr_accessor :current_page, :initial_visit, :page_manager

    def initialize(page_manager)
      @page_manager = page_manager
      @current_page = page_manager.page_number_start_value
      @is_started = false
    end

    def next_page
      @current_page += 1
      next_page_number = @page_manager.leading_zero && (@current_page + 1) < 10 ? "0#{@current_page}" : "#{@current_page}"
      case @page_manager.action_type
      when :get
        next_page = @page_manager.cartridge.base_list_template.gsub('$page_number', next_page_number)
        visit next_page
      when :click
        # debugger
        initial_visit unless @is_started
        find(:xpath, @page_manager.action_value).click
      when :js
        initial_visit unless @is_started
        execute_script(@page_manager.action_value.gsub!('$page_number', next_page_number))
      end
      sleep @page_manager.delay_between_pages
    end

    private

    def initial_visit
      initial_page = @page_manager.cartridge.base_list_template.gsub('$page_number', page_manager.page_number_start_value.to_s)
      visit initial_page
      @is_started = true
    end

    def next_page_number; end
  end
end

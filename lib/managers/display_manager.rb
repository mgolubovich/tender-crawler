# Class that handles virtual displays
class DisplayManager
  def initialize
    @headless = Headless.new(display: 100, destroy_at_exit: false)
    @headless.start
  end

  def destroy
    @headless.destroy
  end
end

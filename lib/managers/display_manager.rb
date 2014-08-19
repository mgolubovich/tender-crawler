# Class that handles virtual displays
class DisplayManager
  def initialize
    @headless = Headless.new(display: 100, destroy_at_exit: false, reuse: true)
  end

  def start
    @headless.start
  end

  def stop
    @headless.stop
  end

  def destroy
    @headless.destroy
  end
end

# Class that handles virtual displays
class DisplayManager
  attr_reader :headless
  def initialize
    @headless = Headless.new(display: 100, destroy_at_exit: false, reuse: true)
  end
end

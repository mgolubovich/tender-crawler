class Reaper
  # Service class, used for keeping
  # params and attrs of Reaper instance
  class ReaperParams
    attr_accessor :source, :args, :status
    attr_reader :display_manager, :nav_manager

    def initialize(source, args)
      @source = source
      @args = args
      @status = {}

      default_values
    end

    def reaped_enough?
      @status[:reaped_tenders_count] >= @args[:limit] ? true : false
    end

    private

    def default_values
      @args[:limit] = 500 unless @args.key? :limit
      @args[:cartridge_id] = nil unless @args.key? :cartridge_id
      @args[:is_checking] = false unless @args.key? :is_checking

      @status[:result] = []
      @status[:reaped_tenders_count] = 0
      @status[:fields_status] = {}
    end
  end
end

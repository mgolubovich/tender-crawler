# Class used for processing work_type and
# setting external_work_type
class WorkTypeProcessor
  class << self
    attr_accessor :construct_fpath, :construct_okpd_fpath
    attr_accessor :project_fpath, :project_okpd_fpath
    attr_accessor :supply_fpath, :supply_okdp_fpath
    attr_accessor :service_fpath
    # attr_accessor :research_fpath

    attr_accessor :construct_keys, :project_keys
    attr_accessor :supply_keys, :service_keys
    # attr_accessor :research_keys

    attr_accessor :exceptions
  end

  @construct_fpath = 'config/work_type_codes/construct.yml'
  @construct_okpd_fpath = 'config/work_type_codes/construct_okpd.yml'
  @project_fpath = 'config/work_type_codes/project.yml'
  @project_okpd_fpath = 'config/work_type_codes/project_okpd.yml'
  @supply_fpath = 'config/work_type_codes/supply.yml'
  @supply_okdp_fpath = 'config/work_type_codes/supply_okpd.yml'
  @service_fpath = 'config/work_type_codes/service_okdp.yml'
  # @research_fpath = 'config/work_type_codes/research.yml'

  @construct_keys = YAML.load_file(WorkTypeProcessor.construct_fpath).keys
  @construct_keys += YAML.load_file(WorkTypeProcessor.construct_okpd_fpath).keys
  @project_keys = YAML.load_file(WorkTypeProcessor.project_fpath).keys
  @project_keys += YAML.load_file(WorkTypeProcessor.project_okpd_fpath).keys
  # @research_keys = YAML.load_file(WorkTypeProcessor.research_fpath).keys
  @supply_keys = YAML.load_file(WorkTypeProcessor.supply_fpath).keys
  @supply_keys += YAML.load_file(WorkTypeProcessor.supply_okdp_fpath).keys
  @service_keys = YAML.load_file(WorkTypeProcessor.service_fpath).keys

  @exceptions = {
    without_dot: {
      1 => %w(451 452 453 454),
      2 => %w(456),
      3 => %w(455 459)
    },
    with_dot: {
      1 => %w(45),
      2 => %w(74.2)
    }
  }

  def initialize(work_type)
    @work_type = work_type
    @e_work_type = 0
  end

  def process
    return -1 if Array(@work_type).empty?

    Array(@work_type).each do |w|
      next if w['code'].blank? || @e_work_type > 0

      @e_work_type = search_in_files(w['code'])
      @e_work_type = search_in_exceptions(w['code']) if @e_work_type.zero?
    end

    # { external_work_type: @e_work_type }
    @e_work_type
  end

  private

  def search_in_files(code)
    return 1 if WorkTypeProcessor.construct_keys.include?(code)
    return 2 if WorkTypeProcessor.project_keys.include?(code)
    # return 3 if WorkTypeProcessor.research_keys.include? w['code']
    return 4 if WorkTypeProcessor.supply_keys.include?(code)
    return 5 if WorkTypeProcessor.service_keys.include?(code)
    0
  end

  def search_in_exceptions(code)
    subset = code.include?('.') ? :with_dot : :without_dot
    WorkTypeProcessor.exceptions[subset].each do |k, v|
      return k if code.start_with?(*v)
    end
    0
  end
end

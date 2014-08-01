# Class for applying rules on values and setting correct status
class Arbiter
  def initialize(selector_value, rule)
    @value = selector_value
    @rule = rule
    @status = :valid
    @arbitrage = {}
  end

  def judge
    @arbitrage[:check_length] = check_length if @rule.check_length.is_a?(Hash)
    @arbitrage[:check_emptiness] = check_emptiness if @rule.check_emptiness
    @arbitrage[:check_regexp] = check_regexp if @rule.check_regexp.length > 0

    @arbitrage.each_pair do |rule, result|
      next unless result == :failed
      @status = @rule.failed_status
      log_rule_failed(rule, @value)
    end

    @status
  end

  def check_length
    result = :passed
    if @rule.check_length.key?(:more)
      result = @value.length > @rule.check_length[:more] ? :passed : :failed
    end
    if @rule.check_length.key?(:less)
      result = @value.length < @rule.check_length[:less] ? :passed : :failed
    end
    if @rule.check_length.key?(:equal)
      result = @value.length == @rule.check_length[:equal] ? :passed : :failed
    end
    result
  end

  def check_emptiness
    @value.length > 0 ? :passed : :failed
  end

  def check_regexp
    Regexp.new(@rule.regexp).match(@value).nil? ? :passed : :failed
  end
end

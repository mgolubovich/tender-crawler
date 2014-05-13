class Arbiter

  def initialize(selector_value, rule)
    @selector_value = selector_value
    @rule = rule
    @status = :valid
    @arbitrage = Hash.new
  end

  def judge
    @arbitrage[:check_length] = check_length
    @arbitrage[:check_emptiness] = check_emptiness
    @arbitrage[:check_regexp] = check_regexp

    @arbitrage.each_pair do |rule, result|
      if result == :failed
        @status = @rule.failed_status
        log_rule_failed(rule, @selector_value)
      end
    end

    @status
  end

  def check_length
    result = :passed
    
    if @rule.check_length.has_key?(:more)
      result = @selector_value.length > @rule.check_length[:more] ? :passed : :failed
    end

    if @rule.check_length.has_key(:less)
      result = @selector_value.length < @rule.check_length[:less] ? :passed : :failed
    end

    if @rule.check_length.has_key(:equal)
      result = @selector_value.length == @rule.check_length[:equal] ? :passed : :failed
    end

    result
  end

  def check_emptiness
    @selector_value.length > 0 ? :passed : :failed
  end

  def check_regexp
    Regexp.new(@rule.regexp).match(@selector_value).nil? ? :passed : :failed
  end

end
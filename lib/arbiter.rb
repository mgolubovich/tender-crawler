class Arbiter

  def initialize(selector_value, rule)
    @selector_value = selector_value
    @rule = rule
    @status = :valid
  end

  def judge

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

end
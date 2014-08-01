# Class for smart-keeping all value variants during parsing
class EntityStub < Hash
  def initialize(data = {})
    self.merge! data
  end

  def insert(key, value)
    self[key.to_sym] = [] unless self.key?(key.to_sym)
    self[key.to_sym] << value
  end

  def attributes
    result = {}
    each_pair do |key, values_set|
      result[key.to_sym] = best_of(values_set)
    end
    result
  end

  def attrs
    attributes
  end

  private

  def best_of(values_set)
    return values_set unless values_set.is_a?(Array)
    return values_set.first if values_set.count == 1

    best = values_set.first
    values_set.each do |value|
      best = value unless value.nil? || (value.is_a?(String) && value.empty?)
    end
    best
  end
end

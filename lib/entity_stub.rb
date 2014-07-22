class EntityStub

  def initialize(data = {})
    @data = data
  end

  def insert(key, value)
    @data[key.to_sym] = [] unless @data.has_key?(key.to_sym)
    @data[key.to_sym] << value
  end

  def data
    result = {}
    @data.each_pair do |key, value|

    end
  end

  private
  
end
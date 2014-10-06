class Array
  def contains?(other)
    (other & self) == other
  end
end
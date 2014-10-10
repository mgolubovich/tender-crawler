# Additional functionality for DateTime class
class DateTime
  def difference_in_seconds(other)
    ((self - other) * 1.day)
  end
end

class Array
  def randomize
    duplicated_original = self.dup
    new_array = self.class.new
    new_array << duplicated_original.slice!(rand(duplicated_original.size)) until new_array.size.eql?(self.size)
    return new_array
  end

  def randomize!
    self.replace(randomize)
  end
end

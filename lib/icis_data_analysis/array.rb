class Array
  def average(attribute=nil)
    return nil if empty?
    inject(0.0){ |sum, el| sum + (attribute.nil? ? el : el.send(attribute)) }.to_f / size
  end
end

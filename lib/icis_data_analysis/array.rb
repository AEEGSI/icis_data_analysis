class Array
  def average(attribute=nil)
    return nil if size==0.0
    inject(0.0){ |sum, el| sum + (attribute.nil? ? el : el.send(attribute)) }.to_f / size
  end
end

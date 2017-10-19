class Writexlsx::Worksheet
  def write_array(row, array)
    col = 0
    array.each do |el|
      write(row, col, el)
      col+=1
    end
  end
end

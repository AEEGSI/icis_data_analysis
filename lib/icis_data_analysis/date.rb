class Date
  # Get the quarter (1,2,3 or 4)
  def quarter
    ((month-1)/3)+1
  end

  # Get the 'two_season', 1 for summer, 0 or 2 for winter
  def two_season
    if month<=3
      0
    elsif month>=10
      2
    else
      1
    end
  end

  # Get the 'Gas year'
  def gas_year
    y = year
    if self< Date.new(y,10,1)
      y
    else
      y+1
    end
  end
end

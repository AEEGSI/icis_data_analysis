$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'icis_data_analysis'


module IcisDataAnalysis

  def read_psv(path, year=2016)
    xlsx = Roo::Excelx.new path

    arr = []
    index = 2
    xlsx.each_row_streaming(offset: 1) do |row| # Will exclude first (inevitably header) row
      puts "-----> #{index}" if index%250==0
      if Date.strptime(row[4].to_s, '%m-%d-%y').year==year # occhio!!! filtro sull'anno
        arr << PSV_Prices.new(row)
      end
      index += 1
    end
    puts "Finished to read psv prices file"
    arr
  end




  def write_output(path, arr, year)
    workbook = WriteXLSX.new path
    worksheet = workbook.add_worksheet "data"

    # Formats: https://cxn03651.github.io/write_xlsx/format.html#format
    format_diff = workbook.add_format
    format_diff.set_num_format("0.000")

    format_price = workbook.add_format
    format_price.set_num_format("0.000")

    format_perc = workbook.add_format
    format_perc.set_num_format(10)


    row = 0
    arr.first.header.each_with_index do |element, i|
      worksheet.write(row, i, element)
    end
    arr.each do |line|
      row+=1
      i=0
      line.hash.each_pair do |k, v|
        frmt = nil
        case k
        when :transaction_date
          v = v.to_s
        when :startdate
          v = v.to_s
        when :enddate
          v = v.to_s
        when :bid
          frmt = format_price
        when :offer
          frmt = format_price
        when :bid_offer_spread
          frmt = format_diff
        when :bid_offer_spread_perc
          frmt = format_perc
        end
        worksheet.write(row, i, v, frmt)
        i+=1
      end
    end


    # ----- day ahead index
    a = arr.select{|el| el.product=="day_ahead"}
    puts "  'day_ahead' lines: #{a.size}"
    worksheet = workbook.add_worksheet "day_ahead_index"
    worksheet.write(0, 0, "Rows found")
    worksheet.write(0, 1, a.size)
    worksheet.write(1, 0, "bid_offer_spread avg")
    worksheet.write(1, 1, a.average(:bid_offer_spread), format_diff)
    worksheet.write(2, 0, "bid_offer_spread_perc avg")
    worksheet.write(2, 1, a.average(:bid_offer_spread_perc), format_perc)

    # ----- front month index
    a = arr.select{|el| el.product=="M1"}
    puts "  'M1' lines: #{a.size}"
    row = 0
    worksheet = workbook.add_worksheet "indice_front_month"
    worksheet.write(row, 0, "Rows found")
    worksheet.write(row, 1, a.size)
    row +=1
    worksheet.write(row, 0, "bid_offer_spread avg")
    worksheet.write(row, 1, a.average(:bid_offer_spread), format_diff)
    row +=1
    worksheet.write(row, 0, "bid_offer_spread_perc avg")
    worksheet.write(row, 1, a.average(:bid_offer_spread_perc), format_perc)

    # ----- forward indexes
    worksheet = workbook.add_worksheet "forward_index"
    indexes_sets = [
      ["M6" ,"Q2","S1"],
      ["M12","Q4","S2","Y1","GY1"],
      ["M18","Q6","S3"],
      ["M24","Q8","S4","Y2","GY2"]
    ]
    # months = ["Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno", "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"]
    months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    row = 0

    header = ["Trading month"] + [6,12,18,24].map{ |m| ["#{m} months index", "", ""]  }.flatten
    worksheet.write_array(row, header)
    row +=1
    worksheet.write_array(row, [""]+["Count", "bid_offer_spread avg", "bid_offer_spread_perc avg"]*4)
    row +=1
    months.each_with_index do |m, i|
      col = 0
      worksheet.write(row, col, "#{m} #{year}")
      col+=1
      indexes_sets.each do |v|
        a = arr.select{|el| el.trading_month==(i+1)}.select{|el| v.include? el.product}
        worksheet.write(row, col, a.size)
        col+=1
        worksheet.write(row, col, a.average(:bid_offer_spread), format_diff)
        col+=1
        worksheet.write(row, col, a.average(:bid_offer_spread_perc), format_perc)
        col+=1
      end
      row +=1
    end
    # Annual average
    col = 0
    worksheet.write(row, 0, "Year #{year} average")
    col+=1
    indexes_sets.each do |v|
      a = arr.select{|el| v.include? el.product}
      worksheet.write(row, col, a.size)
      col+=1
      worksheet.write(row, col, a.average(:bid_offer_spread), format_diff)
      col+=1
      worksheet.write(row, col, a.average(:bid_offer_spread_perc), format_perc)
      col+=1
    end

    # Detailed counts for each product
    row +=2
    header = ["Trading month"]
    indexes = [6,12,18,24].map{ |m| "#{m} months index"  }
    indexes_sets.each_with_index do |v, i|
      header += ([indexes[i]]+[""]*(v.size-1))
    end
    worksheet.write_array(row, header)
    row +=1

    worksheet.write_array(row, [""]+indexes_sets.flatten)
    row +=1

    months.each_with_index do |m, i|
      col = 0
      worksheet.write(row, col, "#{m} #{year}")
      col+=1
      indexes_sets.each do |v|
        v.each do |product|
          a = arr.select{|el| el.trading_month==(i+1)}.select{|el| el.product==product}
          worksheet.write(row, col, a.size)
          col+=1
        end
      end
      row +=1
    end

    # Annual average
    col = 0
    worksheet.write(row, col, "Year #{year} aggreg")
    col+=1
    indexes_sets.each do |v|
      v.each do |product|
        a = arr.select{|el| el.product==product}
        worksheet.write(row, col, a.size)
        col+=1
      end
    end

  ensure
    workbook.close

  end
end




include IcisDataAnalysis



input_path  = '/Users/iwan/dev/elixir/icis_data/input_files/psv_prices.xlsx'
output_path = '/Users/iwan/Desktop/psv_prices_exp.xlsx'

year = 2016
arr  = read_psv(input_path, year)
write_output(output_path, arr, year)

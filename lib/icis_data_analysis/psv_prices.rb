module IcisDataAnalysis
  
  class PSV_Prices
    attr_reader :transaction_date, :startdate, :enddate, :period, :bid, :offer, :trading_month, :trading_quarter, :trading_season, :trading_year, :gas_trading_year, :basic_product, :product, :bid_offer_spread, :bid_offer_spread_perc, :delay, :duration
    @@header = [:dir_date, :file_path, :report_name, :record_id, :transaction_date, :startdate, :enddate, :period, :dataused, :bidcode, :bid, :offercode, :offer, :midpointcode, :midpoint, :code, :diff, :vo]
    @@attributes_array = [:transaction_date, :startdate, :enddate, :period, :bid, :offer, :trading_month, :trading_quarter, :trading_season, :trading_year, :gas_trading_year, :basic_product, :product, :bid_offer_spread, :bid_offer_spread_perc, :delay, :duration]

    def initialize(row_array)
      @transaction_date = read_date cell(row_array, :transaction_date)
      @startdate        = read_date cell(row_array, :startdate)
      @enddate          = read_date cell(row_array, :enddate)
      @period           = cell(row_array, :period).to_s
      @bid              = cell(row_array, :bid).cell_value.to_f
      @offer            = cell(row_array, :offer).cell_value.to_f
      add_extra_fields
      add_calculations
    end

    def header
      @@attributes_array.map(&:to_s)
    end

    def hash
      Hash[@@attributes_array.map{|e| [e, self.send(e)] }]
    end



    private

    def dt
      @transaction_date
    end

    def add_calculations
      @bid_offer_spread      = @offer - @bid
      @bid_offer_spread_perc = @bid_offer_spread / @bid
    end

    def add_extra_fields
      @trading_month    = _trading_month
      @trading_quarter  = _trading_quarter
      @trading_season   = _trading_season
      @trading_year     = _trading_year
      @gas_trading_year = _gas_trading_year
      @basic_product    = _basic_product
      @product          = _product
      @delay            = _delay
      @duration         = _duration
    end

    # count the number of months elapsed since the base date (1-1-2010)
    def count_months(date)
      (date.year-2010)*12 + date.month - 1
    end

    # count the number of quarters elapsed since the base date (1-1-2010)
    def count_quarters(date)
      (date.year-2010)*4 + date.quarter - 1
    end

    # count the number of seasons elapsed since the base date (1-1-2010)
    def count_seasons(date)
      (date.year-2010)*2 + date.two_season - 1
    end

    # count the number of years elapsed since the base date (1-1-2010)
    def count_years(date)
      date.year-2010
    end

    def count_gas_years(date)
      date.gas_year-2010
    end

    def _duration
      @enddate-@startdate+1
    end

    def _delay
      @startdate-dt
    end

    def _product
      case basic_product
      when :month
        "M#{count_months(@startdate)-count_months(dt)}"
      when :quarter
        "Q#{count_quarters(@startdate)-count_quarters(dt)}"
      when :season
        "S#{count_seasons(@startdate)-count_seasons(dt)}"
      when :year
        "Y#{count_years(@startdate)-count_years(dt)}"
      when :gas_year
        "GY#{count_gas_years(@startdate)-count_gas_years(dt)}"
      else
        basic_product.to_s
      end
    end

    def _basic_product
      case @period
      when /day-ahead/i
        :day_ahead
      when /weekend/i
        :weekend
      when /bom/i
        :bom
      when /^q[0-9]/i
        :quarter
      when /^year/i
        :year
      when /^gas/i
        :gas_year
      when /^summer/i
        :season
      when /^winter/i
        :season
      else
        :month
      end
    end

    def _trading_month
      dt.month
    end

    def _trading_quarter
      dt.quarter
    end

    def _trading_season
      dt.two_season==1 ? "summer" : "winter"
    end

    def _trading_year
      dt.year
    end

    def _gas_trading_year
      dt.gas_year
    end

    def read_date(cell)
      Date.strptime(cell.to_s, '%m-%d-%y')
    end

    def cell(row, name)
      i = @@header.index(name)
      i.nil? ? raise("Name '#{name}' not found in header") : row[i]
    end
  end

end
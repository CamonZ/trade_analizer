class TradingDaysController < ApplicationController
  def index
    @ef = TradingDay.new
    @trading_days = TradingDay.by_date
  end
  
  def show
    if params[:date]
      @trading_day = TradingDay.where(:date=>params[:date]).first
    else
      @trading_day = TradingDay.find(params[:id])
    end
    
    respond_to do |format|
      format.html
    end
  end
  
  def upload
    @trading_day = TradingDay.new

    @trading_day.parse(params[:trading_day][:file].tempfile, params[:trading_day][:file].original_filename)
    
    respond_to do |format|
      format.html { redirect_to root_path}
    end
  end
end

class TradingDaysController < ApplicationController
  
  respond_to :html, :json
  def index
    @ef = TradingDay.new
    @trading_days = TradingDay.by_date
    
    respond_with(@trading_days)
  end
  
  def show
    if params.has_key?(:date)
      @trading_day = TradingDay.where(:date=>params[:date]).first
    else
      @trading_day = TradingDay.find(params[:id])
    end
    
    respond_with(@trading_day)
  end
  
  def upload
    @trading_day = TradingDay.new
    @trading_day.parse(params[:trading_day][:file].tempfile, params[:trading_day][:file].original_filename)
    
    respond_to do |format|
      format.html { redirect_to root_path}
    end
  end
  
  def statistics
    if params.has_key?(:date)
      @trading_day = TradingDay.where(:date=>params[:date]).first
    else
      @trading_day = TradingDay.find(params[:id])
    end
    
    resp = @trading_day.statistics_to_json()
    
    respond_with(resp)
  end
end

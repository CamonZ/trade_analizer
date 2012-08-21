class ProfitAndLossStatisticsController < ApplicationController
  respond_to :json
  def statistics
    resp = nil

    if(params.has_key?(:symbol))
      resp = statistics_with_symbol(params[:symbol])
    end
    
    respond_with(resp)
  end
  
  private
  
  def statistics_with_symbol(symbol)
    TradingDay.where(:date=>params[:date]).first.
      stocks_statistics.where(:symbol => symbol).
      first.statistics_to_json()
  end
end

class ProfitAndLossStatisticsController < ApplicationController
  respond_to :json
  def statistics
    resp = TradingDay.where(:date=>params[:date]).first.
      stocks_statistics.where(:symbol => params[:symbol]).
      first.statistics_to_json()
    
    respond_with(resp)
  end
end

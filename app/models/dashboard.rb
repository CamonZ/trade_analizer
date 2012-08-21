class Dashboard
  include Mongoid::Document
  include Mongoid::Timestamps
  
  #fields(fold)
  
  #fields(end)
  
  embeds_many :profit_and_loss_statistics, :cascade_callbacks => true
  has_many :trading_days
  
  def load_executions(file, filename)
    td = TradingDay.new
    td.parse(file, filename)
    
    if(td.valid?)
      trading_days << td
      update_statistics(td)
      save
    end
    
    td.valid?
  end
  
  private 
  
  def update_statistics(trading_day)
    [:cweek, :month, :year].each {|period| update_statistics_for(trading_day, period) }
  end
  
  def update_statistics_for(trading_day, period)
    statistic = profit_and_loss_statistics
      .for_year(trading_day.date.year)
      .find_or_initialize_by({
        :timespan => period, 
        period => trading_day.date.send(period)})
    
    # if the period is not a year it shouldn't respond to it already; let's set the value
    if(!statistic.respond_to?(:year))
      statistic[:year] = trading_day.date.year 
    end
    
    
    statistic.wins += trading_day.wins
    statistic.losses += trading_day.losses
    statistic.winning_trades += trading_day.winning_trades
    statistic.loosing_trades += trading_day.loosing_trades
    statistic.profit_and_loss += trading_day.profit_and_loss
    statistic.comissions += trading_day.comissions
    statistic.net_profit_and_loss = statistic.profit_and_loss + statistic.comissions
    statistic.executions_amount = trading_day.executions.size
    
    if(statistic.new_record?)
      profit_and_loss_statistics << statistic
    end
  end
end

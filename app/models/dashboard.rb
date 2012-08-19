class Dashboard
  include Mongoid::Document
  include Mongoid::Timestamps
  
  #fields(fold)
  
  #fields(end)
  
  embeds_many :profit_and_loss_statistics
  has_many :trading_days
  
  def load_executions(file, filename)
    td = TradingDay.new
    res = td.parse(file, filename)
    
    if(res)
      trading_days << td
      update_statistics
      save
    end
    
    res
  end
  
  private 
  
  def update_statistics; end
end

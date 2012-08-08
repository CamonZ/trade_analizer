class StockProfitAndLoss
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :wins, :type => Float, :default => 0.0
  field :losses, :type => Float, :default => 0.0
  field :profit_and_loss, :type => Float, :default => 0.0
  field :symbol, :type => String
  
  has_many :executions
  embedded_in :trading_day
  
end

class StockProfitAndLoss
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :wins, :type => Float, :default => 0.0
  field :losses, :type => Float, :default => 0.0
  field :profit_and_loss, :type => Float, :default => 0.0
  field :winning_trades, :type => Integer, :default => 0
  field :loosing_trades, :type => Integer, :default => 0
  field :wins_average, :type => Float
  field :losses_average, :type => Float
  field :wins_percentage, :type => Float
  field :symbol, :type => String
  
  before_save :calculate_statistics
  
  has_many :executions
  embedded_in :trading_day
  
  private
  
  def calculate_statistics
    self.wins_average = (self.wins / winning_trades.to_f).round(3)
    self.losses_average = (self.losses / self.loosing_trades.to_f).round(3)
    self.losses_average = (self.losses / self.loosing_trades.to_f).round(3)
    self.wins_percentage = ((self.winning_trades.to_f / (self.winning_trades + self.loosing_trades).to_f) * 100.0).round(3)
  end
end

class StockProfitAndLoss
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :wins, :type => Float, :default => 0.0
  field :losses, :type => Float, :default => 0.0
  field :profit_and_loss, :type => Float, :default => 0.0
  field :winning_trades, :type => Integer, :default => 0
  field :loosing_trades, :type => Integer, :default => 0
  field :flat_trades, :type => Integer, :default => 0
  field :wins_average, :type => Float
  field :losses_average, :type => Float
  field :wins_percentage, :type => Float
  field :symbol, :type => String
  
  before_save :calculate_statistics
  
  has_many :executions
  embedded_in :trading_day
  
  scope :by_profit_and_loss, order_by(:profit_and_loss => :asc)
  
  private
  
  def calculate_statistics
    self.flat_trades = (self.executions.size / 2) - (self.winning_trades + self.loosing_trades)
    self.wins_average = winning_trades.eql?(0) ? 0.0 :(wins / winning_trades.to_f || 1.0).round(3)
    self.losses_average = loosing_trades.eql?(0) ? 0.0 : (losses / loosing_trades.to_f).round(3)
    self.wins_percentage = ((winning_trades.to_f / (winning_trades + loosing_trades).to_f) * 100.0).round(3)
  end
end

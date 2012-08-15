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
  
  def statistics_to_json
    res = {:statistics => []}
    res[:statistics] = generate_statistics_structure
    
    return res
  end
  
  private
  
  def generate_statistics_structure
    res = []
    res.push({
      :title => 'profit_and_loss', 
      :subtitle => '$', 
      :breakdown => { :wins => self.wins.round(2), :losses => self.losses.round(2) },
      :figure => self.profit_and_loss.round(2),
      :unit => '$' })
    
    res.push({
      :title => "wins_percentage",
      :subtitle => "%",
      :breakdown => { :winning_trades => self.winning_trades, :loosing_trades => self.loosing_trades, :flat_trades => self.flat_trades }, 
      :figure => ((self.winning_trades.to_f / (self.loosing_trades.to_f + self.winning_trades.to_f + self.flat_trades.to_f))*100.0).round(2), 
      :unit => "%"
    })
    
    fig = (self.losses == 0.0 ? self.wins : (self.wins.to_f / self.losses.to_f))
    
    res.push({
      :title => "wins/losses_ratio",
      :breakdown => { :average_wins => self.wins_average, :average_losses => self.losses_average }, 
      :figure => fig.round(2).abs, 
      :unit => ""
    })
    
    return res
  end
  
  def calculate_statistics
    self.flat_trades = (self.executions.size / 2) - (self.winning_trades + self.loosing_trades)
    self.wins_average = winning_trades.eql?(0) ? 0.0 :(wins / winning_trades.to_f || 1.0).round(3)
    self.losses_average = loosing_trades.eql?(0) ? 0.0 : (losses / loosing_trades.to_f).round(3)
    self.wins_percentage = ((winning_trades.to_f / (winning_trades + loosing_trades).to_f) * 100.0).round(3)
  end
end

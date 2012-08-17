require 'fileutils'
class TradingDay
  include Mongoid::Document
  include Mongoid::Timestamps
  
  #fields(fold)
  field :date, :type => Date
  field :profit_and_loss, :type => Float
  field :wins, :type => Float
  field :losses, :type => Float
  field :wins_average, :type => Float
  field :losses_average, :type => Float
  field :wins_percentage, :type => Float
  field :winning_trades, :type => Integer, :default => 0
  field :loosing_trades, :type => Integer, :default => 0
  field :flat_trades, :type => Integer, :default => 0
  field :comissions, :type => Float, :default => 0.0
  field :net_profit_and_loss, :type => Float
  #(end)
  
  scope :by_date, order_by(:date => :desc)
  
  has_many :executions, :autosave => true
  embeds_many :stocks_profit_and_loss, :class_name => "StockProfitAndLoss"
  index({"stocks_profit_and_loss.symbol" => 1}, {:unique => true})
  
  before_save :calculate_statistics, :on => :create
  
  validates_presence_of :date
  
  @@fields_to_sym = {
    "Exec Time" => :execution_time, 
    "Symbol" => :symbol,
    "Executed Shares" => :shares, 
    "Price" => :price, 
    "Side" => :side, 
    "Contra" => :contra, 
    "Liquidity" => :liquidity, 
    "P&L" => :profit_and_loss
  }
  
  @@fieldnames_to_methods = {
    "Exec Time" => "datetime",
    "Symbol" => "string",
    "Side" => "string",
    "Contra" => "string",
    "Executed Shares" => "shares",
    "Price" => "float",
    "P&L" => "float",
    "Liquidity" => "liquidity"
  }
  
  def parse(file, filename)
    self.date = get_date_from_filename(filename)
    
    
    if !has_required_columns?(file.readline)
      return false;
    end
    
    file.rewind
    
    field_names = file.readline.scan(/([[:print:]]+)\t?/).flatten
    
    execs = []
    
    file.each_line do |l|
      fields = l.scan(/([[:print:]]+)\t?/).flatten
      
      execution_fields = {}
      
      execution_fields[:date] = self.date
      
      field_names.each do |fn|
        execution_fields[@@fields_to_sym[fn]] = self.send(("parse_" + @@fieldnames_to_methods[fn]).to_sym, fields)
      end
      
      execution_fields[:time_of_day] = set_time_of_day(execution_fields[:execution_time])
      execution_fields[:comissions] = set_comission_costs(execution_fields[:shares])
      execs << execution_fields
    end
      
    create_executions(execs)
    save
  end
  
  def statistics_to_json()
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
      :title => 'net_profit_and_loss', 
      :subtitle => '$', 
      :breakdown => { :gross_profit_and_loss => self.profit_and_loss.round(2), :comissions => self.comissions.round(2) },
      :figure => self.net_profit_and_loss.round(2),
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
  
  def has_required_columns?(first_line)
    columns = ["Exec Time", "Symbol", "Executed Shares", "Price", "Side", "Contra", "Liquidity", "P&L"]
    matches = first_line.scan(/([[:print:]]+)\t?/).flatten
    return true if columns - matches == [] && matches - columns == [] 
    return false
  end
  
  def get_date_from_filename(filename)
    /(\d+-\d+-\d+)\..+$/.match(filename)
    Date.parse($1)
  end
  
  def parse_datetime(f)
    DateTime.parse(self.date.to_s + " " + f.shift)
  end
  
  def parse_string(f)
    f.shift.strip
  end
  
  def parse_shares(f)
    f.shift.to_i
  end
  
  def parse_float(f)
    if f.empty?
      nil
    else
      f.shift.to_f
    end
  end
  
  def parse_liquidity(f)
    liq_field = f.shift.scan(/(\d+)\/(\d+)/).flatten
    liq_field = liq_field[0].to_i < liq_field[1].to_i ? -liq_field[1].to_i : liq_field[1].to_i
    liq_field
  end
  
  def set_time_of_day(execution_time)
    pre = DateTime.parse(self.date.to_s + " 09:30:00")
    open = DateTime.parse(self.date.to_s + " 11:00:00")
    midday = DateTime.parse(self.date.to_s + " 14:30:00")
    close = DateTime.parse(self.date.to_s + " 16:00:00")
    
    res = ""
    
    if(execution_time < pre)
      res = "premarket"
    elsif(execution_time < open)
      res = "open"
    elsif(execution_time < midday)
      res = "midday"
    elsif(execution_time < close)
      res = "close"
    else
      res = "aftermarket"
    end
    
    res
  end
  
  def set_comission_costs(shares)
    ((shares <= 222) ? 1.0 : (shares.to_f * 0.0045)) * -1.0
  end
  
  def create_executions(execs)
    execs.each {|e| create_execution_from_hash(e) if e[:shares] > 0}
  end
  
  def create_execution_from_hash(values)
    exec = Execution.new(values)
    self.executions << exec
  end
  
  def calculate_statistics
    execs = executions.select {|e| e.profit_and_loss != nil }

    self.profit_and_loss = execs.inject(0.0) {|sum, e| sum + (e.profit_and_loss || 0.0) }
    self.wins = execs.select {|e| e.profit_and_loss > 0.0}.inject(0.0) {|sum, e| sum + e.profit_and_loss }
    self.losses = execs.select {|e| e.profit_and_loss  < 0.0}.inject(0.0) {|sum, e| sum + e.profit_and_loss }
    
    self.winning_trades = execs.select {|e| e.profit_and_loss > 0.0}.size
    self.loosing_trades = execs.select {|e| e.profit_and_loss < 0.0}.size
    self.flat_trades = (executions.size / 2) - (winning_trades + loosing_trades)
    
    self.wins_average = (winning_trades == 0 ? 0 : (wins / winning_trades.to_f))
    self.wins_average = self.wins_average.round(2)
    
    self.losses_average = (loosing_trades == 0 ? 0 : (losses / loosing_trades.to_f))
    self.losses_average = self.losses_average.round(2)
    
    self.wins_percentage = ((winning_trades.to_f / (winning_trades + loosing_trades).to_f) * 100.0).round(2)
    
    executions.each do |e|
      stock_pnl = stocks_profit_and_loss.find_or_initialize_by(:symbol => e.symbol)

      if e.profit_and_loss != nil #calculate the pnl and stats for each execution that has a positive or negative pnl
        if e.profit_and_loss > 0.0
          stock_pnl.wins += e.profit_and_loss
          stock_pnl.winning_trades += 1
        elsif e.profit_and_loss < 0.0
          stock_pnl.losses += e.profit_and_loss
          stock_pnl.loosing_trades += 1
        end
        stock_pnl.profit_and_loss = stock_pnl.wins + stock_pnl.losses
      end

      stock_pnl.executions << e
      
      self.comissions += e.comissions
      stock_pnl.comissions += e.comissions
    end
    
    stocks_profit_and_loss.each do |spnl|
      spnl.net_profit_and_loss = spnl.profit_and_loss + spnl.comissions
      spnl.send(:calculate_statistics)
    end
    
    self.net_profit_and_loss = self.profit_and_loss + self.comissions
  end
end

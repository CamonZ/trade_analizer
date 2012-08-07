require 'fileutils'
class ExecutionsDay
  include Mongoid::Document
  include Mongoid::Timestamps
  
  #fields(fold)
  field :date, :type => Date
  field :best_stock, :type => String
  field :worst_stock, :type => String
  field :profit_and_loss, :type => Float
  field :wins, :type => Float
  field :losses, :type => Float
  field :wins_average, :type => Float
  field :losses_average, :type => Float
  field :wins_percentage, :type => Float
  field :losses_percentage, :type => Float
  #(end)
  
  scope :by_date, order_by(:date => :desc)
  
  has_many :executions
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
      
      field_names.each do |fn|
        execution_fields[:date] = self.date
        execution_fields[@@fields_to_sym[fn]] = self.send(("parse_" + @@fieldnames_to_methods[fn]).to_sym, fields)
      end

      execs << execution_fields
    end
    
    create_executions(execs)
    
    save
  end
  
  private
  
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
    f.shift.to_f
  end
  
  def parse_liquidity(f)
    liq_field = f.shift.scan(/(\d+)\/(\d+)/).flatten
    liq_field = liq_field[0].to_i < liq_field[1].to_i ? -liq_field[1].to_i : liq_field[1].to_i
    liq_field
  end
  
  def create_executions(execs)
    execs.each do |e|
      create_execution_from_hash(e) if e[:shares] > 0
    end
  end
  
  def create_execution_from_hash(values)
    @exec = Execution.new(values)
    self.executions << @exec
  end
  
  def calculate_statistics
    self.profit_and_loss = executions.inject(0.0) {|sum, e| sum + e.profit_and_loss }
    self.wins = executions.select {|e| e.profit_and_loss > 0.0}.inject(0.0) {|sum, e| sum + e.profit_and_loss }
    self.losses = executions.select {|e| e.profit_and_loss < 0.0}.inject(0.0) {|sum, e| sum + e.profit_and_loss }
    self.wins_average = self.wins / executions.select {|e| e.profit_and_loss > 0.0}.size
    self.losses_average = self.losses / executions.select {|e| e.profit_and_loss < 0.0}.size
    self.wins_percentage = (executions.select {|e| e.profit_and_loss > 0.0}.size.to_f / executions.select{|e| e.profit_and_loss != 0 }.size.to_f) * 100.0
    self.losses_percentage = (executions.select {|e| e.profit_and_loss < 0.0}.size.to_f / executions.select{|e| e.profit_and_loss != 0 }.size.to_f) * 100.0
    
    executions.each do |e|
      stock_pnl = stocks_profit_and_loss.find_or_initialize_by(:symbol => e.symbol)
      
      if e.profit_and_loss > 0
        stock_pnl.wins += e.profit_and_loss
      else
        stock_pnl.losses += e.profit_and_loss
      end
      stock_pnl.profit_and_loss = stock_pnl.wins + stock_pnl.losses
      stock_pnl.executions << e
    end
  end
end

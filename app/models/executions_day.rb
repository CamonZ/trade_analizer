require 'fileutils'
class ExecutionsDay < ActiveRecord::Base
  has_many :executions, :order => :time
  
  validates_presence_of :date
  
  @@fields_to_sym = {
    "Exec Time" => :time, 
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
end

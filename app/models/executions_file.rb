require 'fileutils'
class ExecutionsFile < ActiveRecord::Base
  has_many :executions
  
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
  
  def parse(file, filename)
    date = get_date_from_filename(filename)

    return has_required_columns?(file.readline)

    file.rewind
    field_names = file.readline.scan(/([[:print:]]+)\t?/).flatten
    file.each_line do |l|
      fields = l.scan(/([[:print:]]+)\t?/).flatten
      
      execution_fields = {}
      
      field_names.each do |fn|
        case fn
        when fn == "Exec Time"
          execution_fields[@@fields_to_sym[fn]] = DateTime.parse(date.to_s + " " + fields.shift)
          break;
        when fn == "Symbol" || fn == "Side" || fn == "Contra"
          execution_fields[@@fields_to_sym[fn]] = fields.shift.lstrip
          break;
        when fn == "Executed Shares"
          execution_fields[@@fields_to_sym[fn]] = fields.shift.to_i
          break;
        when fn == "Price" || fn == "P&L"
          execution_fields[@@fields_to_sym[fn]] = fields.shift.to_f
          break;
        when fn == "Liquidity"
          liq_field = fields.shift.scan(/(\d+)\/(\d+)/).flatten
          if liq_field[0].to_i < liq_field[1].to_i 
            execution_fields[@@fields_to_sym[fn]] = -liq_field[1].to_i
          else 
            execution_fields[@@fields_to_sym[fn]] = liq_field[1].to_i
          end
          break;
        end
        
        execution = Execution.new(execution_fields)
        
      end
    end
    
  end
  
  private
  
  def has_required_columns?(first_line)
    columns = ["Exec Time", "Symbol", "Executed Shares", "Price", "Side", "Contra", "Liquidity", "P&L"]
    matches = first_line.scan(/([[:print:]]+)\t?/).flatten
    return true if columns - matches == [] && matches - columns == [] 
    return false
  end
  
  def get_date_from_filename(filename)
    /(\d+-\d+-\d+)\..+$/.match(str)
    Date.parse($1)
  end
end

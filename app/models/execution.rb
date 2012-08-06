class Execution < ActiveRecord::Base
  attr_accessible :contra, :date, :liquidity, :price, :profit_and_loss, :shares, :side, :symbol, :time
  
  validates_presence_of :contra, :date, :liquidity, :price, :shares, :side, :symbol, :time
  
  validates_numericality_of :shares, :only_integer => true, :greater_than => 0
  
  belongs_to :executions_day
end

class Execution < ActiveRecord::Base
  attr_accessible :contra, :date, :liquidity, :price, :profit_and_loss, :shares, :side, :symbol, :time
  
  validates_presence_of :contra, :date, :liquidity, :price, :profit_and_loss, :shares, :side, :symbol, :time
end

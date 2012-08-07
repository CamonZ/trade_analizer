class Execution
  include Mongoid::Document
  include Mongoid::Timestamps
  
  #Fields(fold)
  field :date, :type => Date
  field :execution_time, :type => DateTime
  field :symbol, :type => String
  field :side, :type => String
  field :contra, :type => String
  field :shares, :type => Integer
  field :liquidity, :type => Integer
  field :price, :type => Float
  field :profit_and_loss, :type => Float, :default => 0.0
  #(end)
  
  attr_accessible :contra, :date, :liquidity, :price, :profit_and_loss, :shares, :side, :symbol, :execution_time
  validates_presence_of :contra, :date, :liquidity, :price, :shares, :side, :symbol, :execution_time
  validates_numericality_of :shares, :only_integer => true, :greater_than => 0
  belongs_to :executions_day
end

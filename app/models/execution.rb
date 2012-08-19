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
  field :profit_and_loss, :type => Float
  field :comissions, :type => Float, :default => 0.0
  field :net_profit_and_loss, :type => Float
  field :time_of_day, :type => String
  #(end)
  
  attr_accessible :date, :execution_time, :symbol, :side, :contra, :shares, :liquidity, :price, :profit_and_loss, :time_of_day, :comissions
  validates_presence_of :contra, :date, :liquidity, :price, :shares, :side, :symbol, :execution_time, :time_of_day, :comissions
  validates_numericality_of :shares, :only_integer => true, :greater_than => 0

  belongs_to :trading_day, :index => true
  
  scope :by_time, order_by(:execution_time => :asc)
end

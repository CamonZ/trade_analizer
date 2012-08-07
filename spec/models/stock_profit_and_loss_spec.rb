require 'spec_helper'

describe StockProfitAndLoss do
  it { should have_field(:wins).of_type(Float).with_default_value_of(0.0) }
  it { should have_field(:losses).of_type(Float).with_default_value_of(0.0) }
  it { should have_field(:profit_and_loss).of_type(Float).with_default_value_of(0.0) }
  it { should have_field(:symbol).of_type(String) }
  
  it { should be_embedded_in(:executions_day) }
  it { should have_many(:executions) }
end

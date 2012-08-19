require 'spec_helper'

describe ProfitAndLossStatistic do
  it { should have_field(:wins).of_type(Float).with_default_value_of(0.0) }
  it { should have_field(:losses).of_type(Float).with_default_value_of(0.0) }
  it { should have_field(:profit_and_loss).of_type(Float).with_default_value_of(0.0) }
  it { should have_field(:winning_trades).of_type(Integer).with_default_value_of(0) }
  it { should have_field(:loosing_trades).of_type(Integer).with_default_value_of(0) }
  it { should have_field(:flat_trades).of_type(Integer).with_default_value_of(0) }
  it { should have_field(:wins_average).of_type(Float) }
  it { should have_field(:losses_average).of_type(Float) }
  it { should have_field(:wins_percentage).of_type(Float) }
  
  it { should be_embedded_in(:trading_day) }
  it { should have_many(:executions) }
  
  describe "when calculating the stock statistics" do
    before do
      @stock_profit_and_loss = ProfitAndLossStatistic.new(
        {
          :wins => 61.5, 
          :losses => -16.66, 
          :profit_and_loss => 44.84,
          :winning_trades => 8,
          :loosing_trades => 5
        }
      )
      @stock_profit_and_loss.send(:calculate_statistics)
    end

    it "should calculate the wins_average" do
      @stock_profit_and_loss.wins_average.should == 7.688
    end
    
    it "should calculate the losses_average" do
      @stock_profit_and_loss.losses_average.should == -3.332
    end
    
    it "should calculate the wins_percentage" do
      @stock_profit_and_loss.wins_percentage.should == 61.538
    end
  end
end

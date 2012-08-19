require 'spec_helper'

describe Execution do
  subject { FactoryGirl.create(:execution) }
  it { should have_field(:date).of_type(Date) }
  it { should have_field(:execution_time).of_type(DateTime) }
  it { should have_field(:symbol).of_type(String) }
  it { should have_field(:shares).of_type(Integer) }
  it { should have_field(:price).of_type(Float) }
  it { should have_field(:side).of_type(String) }
  it { should have_field(:contra).of_type(String) }
  it { should have_field(:liquidity).of_type(Integer) }
  it { should have_field(:profit_and_loss).of_type(Float) }
  
  should_validate_presence_of :date
  should_validate_presence_of :execution_time
  should_validate_presence_of :symbol
  should_validate_presence_of :shares
  should_validate_presence_of :price
  should_validate_presence_of :side
  should_validate_presence_of :contra
  should_validate_presence_of :liquidity
  
  it { should validate_numericality_of(:shares).to_allow(:only_integer => true, :greater_than => 0) }
  
  it {should belong_to :trading_day}
end

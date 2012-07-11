require 'spec_helper'

describe Execution do
  subject { FactoryGirl.create(:execution) }
  describe "database table" do
    should_have_column( 'date', :type => :date)
    should_have_column('time', :type => :datetime)
    should_have_column('symbol', :type => :string)
    should_have_column('shares', :type => :integer)
    should_have_column('price', :type => :float)
    should_have_column('side', :type => :string)
    should_have_column('contra', :type => :string)
    should_have_column('liquidity', :type => :integer)
    should_have_column('profit_and_loss', :type => :float)
    
  end
  
  should_validate_presence_of :date
  should_validate_presence_of :time
  should_validate_presence_of :symbol
  should_validate_presence_of :shares
  should_validate_presence_of :price
  should_validate_presence_of :side
  should_validate_presence_of :contra
  should_validate_presence_of :liquidity
  should_validate_presence_of :profit_and_loss
  
  should_belong_to :executions_file
end

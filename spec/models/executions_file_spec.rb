require 'spec_helper'

describe ExecutionsFile do
  should_respond_to :parse
  should_have_many :executions
  describe "When parsing the executions file" do
    before do
      @executions_file = ExecutionsFile.new
    end
    it "should determine if the file has the needed columns" do
      first_line = "Exec Time	Symbol	Executed Shares	Price	Side	Contra	Liquidity	P&L"
      @executions_file.send(:has_required_columns?, first_line).should == true
    end
    
    it "should fail parsing if the file does not have the needed columns" do
      first_line = "Exec Time	Symbol	Executed Shares	Price	Side	Contra	Liquidity	Blah"
      @executions_file.send(:has_required_columns?, first_line).should == false
    end
    
    it "should create an Execution from each execution in the file" do
      pending
    end
    it "should assign the executions_file_id to the created executions"
  end
end

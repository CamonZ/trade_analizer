require 'spec_helper'
require 'fileutils'

describe ExecutionsFile do
  should_respond_to :parse
  should_have_many :executions
  
  should_validate_presence_of :date
  
  describe "When parsing the executions file" do
    before do
      @executions_file = ExecutionsFile.new
    end
    
    describe " when parsing the liquidity for the stock" do
      it "should assign a negative value when removing liquidity" do
        f = ["0/100"]
        @executions_file.send(:parse_liquidity, f).should == -100
      end
      
      it "should assign a positive value when adding liquidity" do
        f = ["100/100"]
        @executions_file.send(:parse_liquidity, f).should == 100
      end
      
      it "should assign a 0 when there were no executed shares" do
        f = ["0/0"]
        @executions_file.send(:parse_liquidity, f).should == 0
      end
    end
    
    
    it "should determine if the file has the needed columns" do
      first_line = "Exec Time	Symbol	Executed Shares	Price	Side	Contra	Liquidity	P&L"
      @executions_file.send(:has_required_columns?, first_line).should == true
    end
    
    it "should fail parsing if the file does not have the needed columns" do
      first_line = "Exec Time	Symbol	Executed Shares	Price	Side	Contra	Liquidity	Blah"
      @executions_file.send(:has_required_columns?, first_line).should == false
    end
    
    describe "when creating the executions" do
      before do
        @d = Date.parse("2012-07-13")
      end
      
      it "should create an Execution from a executions hash" do
        hsh = {
          :date => @d,
          :time => DateTime.parse(@d.to_s + " " + "09:30:00"),
          :symbol => "ONXX",
          :shares => 100,
          :price => 78.00,
          :contra => 'ARCA',
          :side => "SSD",
          :liquidity => -100
        } 
        @executions_file.send(:create_execution_from_hash, hsh)
        @executions_file.executions.size == 1
      end
    
      it "should disregard orders with non executed shares" do
        execs = [
          { 
            :date => @d,
            :time => DateTime.parse(@d.to_s + " " + "09:30:00"),
            :symbol => "ONXX",
            :shares => 100,
            :price => 78.00,
            :contra => 'ARCA',
            :side => "SSD",
            :liquidity => 100
          },
          { 
            :date => @d,
            :time => DateTime.parse(@d.to_s + " " + "09:30:10"),
            :symbol => "ONXX",
            :shares => 0,
            :price => 77.85,
            :contra => 'ARCA',
            :side => "BOT",
            :liquidity => 0
          },
          { 
            :date => @d,
            :time => DateTime.parse(@d.to_s + " " + "09:30:10"),
            :symbol => "ONXX",
            :shares => 100,
            :price => 77.5,
            :contra => 'ARCA',
            :side => "BOT",
            :liquidity => 100,
            :profit_and_loss => 50.0
          },
        ]
      
        @executions_file.send(:create_executions, execs)
        @executions_file.executions.size.should == 2
      end
    end
    
    it "should properly parse the execution time and date" do
      @executions_file.send(:parse_datetime, Date.parse("2012-07-13"), ["09:30:00"]).to_s.should == "2012-07-13T09:30:00+00:00"
    end
    
    it "should properly parse the amount of executed shares" do
      @executions_file.send(:parse_shares, ["100"]).should == 100
    end
    
    it "should properly parse the Price and reported PnL by the platform" do
      @executions_file.send(:parse_float, ["30.0"]).should == 30.0
      @executions_file.send(:parse_float, ["-15.29"]).should == -15.29
    end
    
    it "should properly parse the Symbol, Side and Contra for the stock" do
      @executions_file.send(:parse_string, [" ARCA"]).should == "ARCA"
      @executions_file.send(:parse_string, [" SSD "]).should == "SSD"
    end
    
  end
end

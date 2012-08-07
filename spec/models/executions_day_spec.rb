require 'spec_helper'
require 'fileutils'

describe ExecutionsDay do
  should_respond_to :parse
  should_have_many :executions
  it{ should embed_many(:stocks_profit_and_loss) }
  it { should have_index_for("stocks_profit_and_loss.symbol" => 1).with_options(unique: true) }
  
  should_validate_presence_of :date
  
  describe "When parsing the executions file" do
    before do
      @executions_day = ExecutionsDay.new
      @executions_day.date = Date.parse("2012-07-13")
    end
    
    describe " when parsing the liquidity for the stock" do
      it "should assign a negative value when removing liquidity" do
        f = ["0/100"]
        @executions_day.send(:parse_liquidity, f).should == -100
      end
      
      it "should assign a positive value when adding liquidity" do
        f = ["100/100"]
        @executions_day.send(:parse_liquidity, f).should == 100
      end
      
      it "should assign a 0 when there were no executed shares" do
        f = ["0/0"]
        @executions_day.send(:parse_liquidity, f).should == 0
      end
    end
    
    
    it "should determine if the file has the needed columns" do
      first_line = "Exec Time	Symbol	Executed Shares	Price	Side	Contra	Liquidity	P&L"
      @executions_day.send(:has_required_columns?, first_line).should == true
    end
    
    it "should fail parsing if the file does not have the needed columns" do
      first_line = "Exec Time	Symbol	Executed Shares	Price	Side	Contra	Liquidity	Blah"
      @executions_day.send(:has_required_columns?, first_line).should == false
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
        @executions_day.send(:create_execution_from_hash, hsh)
        @executions_day.executions.size == 1
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
      
        @executions_day.send(:create_executions, execs)
        @executions_day.executions.size.should == 2
      end
    end
    
    it "should properly parse the execution time and date" do
      @executions_day.send(:parse_datetime, ["09:30:00"]).to_s.should == "2012-07-13T09:30:00+00:00"
    end
    
    it "should properly parse the amount of executed shares" do
      @executions_day.send(:parse_shares, ["100"]).should == 100
    end
    
    it "should properly parse the Price and reported PnL by the platform" do
      @executions_day.send(:parse_float, ["30.0"]).should == 30.0
      @executions_day.send(:parse_float, ["-15.29"]).should == -15.29
    end
    
    it "should properly parse the Symbol, Side and Contra for the stock" do
      @executions_day.send(:parse_string, [" ARCA"]).should == "ARCA"
      @executions_day.send(:parse_string, [" SSD "]).should == "SSD"
    end
  end

  describe "when calculating the statistics of the executions day" do
    before do
      @executions_day = ExecutionsDay.new
      @executions_file = File.open(File.join(::Rails.root, 'spec', 'factories', "OrdersTest 2012-07-14.txt"))
    end
      
    it "should calculate the daily pnl" do
      @executions_day.parse(@executions_file, "Orders 2012-07-14.txt")
      @executions_day.profit_and_loss.should == 22.35
    end
      
    it "should calculate the winnings for the day" do
      @executions_day.parse(@executions_file, "Orders 2012-07-14.txt")
      @executions_day.wins.should == 27.0
    end
      
    it "should calculate the losses for the day" do
      @executions_day.parse(@executions_file, "Orders 2012-07-14.txt")
      @executions_day.losses.should == -4.65
    end
      
    it "should calculate the winning average for the day" do
      @executions_day.parse(@executions_file, "Orders 2012-07-14.txt")
      @executions_day.wins_average.should == 9
    end
      
    it "should calculate the losses average for the day" do
      @executions_day.parse(@executions_file, "Orders 2012-07-14.txt")
      @executions_day.losses_average.should == -4.65
    end
      
    it "should calculate the win percentage rate" do
      @executions_day.parse(@executions_file, "Orders 2012-07-14.txt")
      @executions_day.wins_percentage.should == 75.0
    end
      
    it "should calculate the losses percentage rate" do
      @executions_day.parse(@executions_file, "Orders 2012-07-14.txt")
      @executions_day.losses_percentage.should == 25.0
    end
    
    describe "when breaking down the pnl for each stock on the trading day on the Stocks Profit and Loss Collection" do
      before do
        @executions_file = File.open(File.join(::Rails.root, 'spec', 'factories', "Orders 2012-07-02.txt"))
        @executions_day.parse(@executions_file, "Orders 2012-07-02.txt")
      end
      
      it "should have one instance per stock each traded" do
        @executions_day.stocks_profit_and_loss.size.should == 4
      end
      
      it "an instance should have the wins for the stock" do
        @executions_day.stocks_profit_and_loss.where(:symbol => "NKE").first.wins.should == 61.5
      end
      
      it "an instance should have has the losses for the stock" do
        @executions_day.stocks_profit_and_loss.where(:symbol => "NKE").first.losses.should == -16.66
      end
      
      it "an instance should have the profit_and_loss for the stock" do
        @executions_day.stocks_profit_and_loss.where(:symbol => "NKE").first.profit_and_loss.should == 44.84
      end
      
      it "an instance related executions should be accesible from the instance" do
        @executions_day.stocks_profit_and_loss.where(:symbol => "NKE").first.respond_to?(:executions).should == true
      end
      
      it "an instance should have the right amount of executions" do
        @executions_day.stocks_profit_and_loss.where(:symbol => "NKE").first.executions.size.should == 28
      end
      
    end
    
  end
  
end

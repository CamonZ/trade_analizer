# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :execution do
    date "2012-07-07"
    execution_time "2012-07-07 16:47:24"
    time_of_day "aftermarket"
    symbol "SINA"
    shares 100
    price 1.5
    side "BOT"
    contra "EDGX"
    liquidity 100
    profit_and_loss 1.5
  end
end

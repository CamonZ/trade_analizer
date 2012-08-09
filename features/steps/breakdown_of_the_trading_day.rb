class BreakdownOfTheTradingDay < Spinach::FeatureSteps
  Given 'I visit a trading day\'s page' do
    click_link("2012-07-02")
  end

  Then 'I should see a the statistics for the trading day' do
    within("#day_statistics") do
      page.should have_content("Wins")
      page.should have_content("Losses")
      page.should have_content("Profit and Loss")
      page.should have_content("Wins Average")
      page.should have_content("Losses Average")
      page.should have_content("Winning Trades")
      page.should have_content("Loosing Trades")
      page.should have_content("Wins Percentage")
    end
  end

  And 'I should see the statistics for each stock traded' do
    within("#stock_statistics") do
      within("#NKE") do
        page.should have_content("Wins")
        page.should have_content("Losses")
        page.should have_content("Profit and Loss")
        page.should have_content("Wins Average")
        page.should have_content("Losses Average")
        page.should have_content("Winning Trades")
        page.should have_content("Loosing Trades")
        page.should have_content("Wins Percentage")
        page.should have_selector(".executions")
      end
    end
  end

  Given 'I visit the homepage' do
    visit "/"
  end

  And 'I upload an executions file' do
    attach_file("trading_day_file", File.join(::Rails.root, 'spec', 'factories', "Orders 2012-07-02.txt"))
    click_button("Upload Executions")
  end
end

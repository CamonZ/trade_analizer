class UploadingAnExecutionsFile < Spinach::FeatureSteps
  Given 'I visit the homepage' do
    visit "/"
  end

  And 'I upload an executions file' do
    attach_file("executions_day_file", File.join(::Rails.root, 'spec', 'factories', "OrdersTest 2012-07-14.txt"))
    click_button("Upload Executions")
  end

  Then 'I should see a link to the day\'s executions' do
    find_link("2012-07-14").visible?
  end
end

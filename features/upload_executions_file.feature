Feature: Uploading an Executions File
  Scenario: An User uploads an executions file
    Given I visit the homepage
    And I upload an executions file
    Then I should see a link to the day's executions
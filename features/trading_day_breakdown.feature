Feature: Breakdown of the trading day
  Once the user has uploaded an executions file and visits the trading day for that file
  He should get the statistics for the day as well as the statistics for each traded stock

  Background:
    Given I visit the homepage
    And I upload an executions file

  Scenario: An User uploads an executions file
    Given I visit a trading day's page
    Then I should see a the statistics for the trading day
    And I should see the statistics for each stock traded

@asia2016
Feature: top header links
  In order to verify functionality
  As an anonymous user

  Scenario: Test the ability to press link in top header
    Given I am on "asia2016"
    When I click "Travel"
    Then I should see "Travel"
  Scenario: Test the ability to press link in top header
    Given I am on "asia2016"
    When I click "Community"
    Then I should see "Community"
  Scenario: Test the ability to press link in top header
    Given I am on "asia2016"
    When I click "About"
    Then I should see "About"

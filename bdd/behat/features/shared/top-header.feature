@shared
Feature: top header links
  In order to verify functionality
  As an anonymous user

  Scenario: Test the ability to press link in top header
    Given I am on the homepage
    When I click "Community" in the "top header" region
    Then I should see "Community"
  Scenario: Test the ability to press link in top header
    Given I am on the homepage
    When I click "Community" in the "top header" region
    Then I should see "Community"

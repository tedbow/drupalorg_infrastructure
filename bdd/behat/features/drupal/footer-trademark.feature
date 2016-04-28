@drupal
Feature: Registered trademark in footer
  In order to show trademark is present
  As an anonymous user, I should see "registered trademark"

  Scenario: Test the ability to press link in top header
    Given I am on the homepage
    Then I should see "registered trademark"

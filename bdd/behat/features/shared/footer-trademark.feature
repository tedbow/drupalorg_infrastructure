@shared
Feature: Test DrupalContext
  In order to prove functionality
  As an anonymous user

  Scenario: Test the ability to press link in top header
    Given I am on the homepage
    Then I should see "registered trademark" in the "footer" region

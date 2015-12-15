@api @events
Feature: Create users with roles
  In order to verify user creation
  As a user of events.drupal.org
  I need to create users of various roles

  Scenario: administrator role
    Given I am logged in as a user with the "administrator" role
    When I click "View Profile"
    Then I should be on "user"
  Scenario: authenticated user role
    Given I am logged in as a user with the "authenticated user" role
    When I click "View Profile"
    Then I should be on "user"

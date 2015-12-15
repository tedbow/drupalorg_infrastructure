@api @events
Feature: Create users with roles
  In order to verify user creation
  As a user of events.drupal.org
  I need to create users of various roles

  Scenario: authenticated user role
    Given I am logged in as a user with the "authenticated user" role
    When I go to "user"
    Then I should be on "user"
  Scenario: confirmed role
    Given I am logged in as a user with the "confirmed" role
    When I go to "user"
    Then I should be on "user"
  Scenario: sponsor organizer role
    Given I am logged in as a user with the "sponsor organizer" role
    When I go to "user"
    Then I should be on "user"
  Scenario: attendee manager role
    Given I am logged in as a user with the "attendee manager" role
    When I go to "user"
    Then I should be on "user"
  Scenario: community role
    Given I am logged in as a user with the "community" role
    When I go to "user"
    Then I should be on "user"
  Scenario: session organizerrole
    Given I am logged in as a user with the "session organizer" role
    When I go to "user"
    Then I should be on "user"
  Scenario: administrator role
    Given I am logged in as a user with the "administrator" role
    When I go to "user"
    Then I should be on "user"

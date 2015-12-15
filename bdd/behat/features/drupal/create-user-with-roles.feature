@api @dupal
Feature: Drush driver
  In order to show functionality of user creation
  As a user of drupal.org
  I need to create users of various roles

  Scenario: administrator role
    Given I am logged in as a user with the "administrator" role
    When I click "View Profile"
    Then I should be on "user"
  Scenario: authenticated user role
    Given I am logged in as a user with the "authenticated user" role
    When I click "View Profile"
    Then I should be on "user"
  Scenario: Git vetted user role
    Given I am logged in as a user with the "Git vetted user" role
    When I click "View Profile"
    Then I should be on "user"
  Scenario: confirmed  role
    Given I am logged in as a user with the "confirmed" role
    When I click "View Profile"
    Then I should be on "user"
  Scenario: community role
    Given I am logged in as a user with the "community" role
    When I click "View Profile"
    Then I should be on "user"
  Scenario: content moderator role
    Given I am logged in as a user with the "content moderator" role
    When I click "View Profile"
    Then I should be on "user"
  Scenario: Documentation moderator role
    Given I am logged in as a user with the "Documentation moderator" role
    When I click "View Profile"
    Then I should be on "user"
  Scenario: Full HTML user role
    Given I am logged in as a user with the "Full HTML user" role
    When I click "View Profile"
    Then I should be on "user"
  Scenario: Packaging whitelist maintainer role
    Given I am logged in as a user with the "Packaging whitelist maintainer" role
    When I click "View Profile"
    Then I should be on "user"
  Scenario: testing administrator role
    Given I am logged in as a user with the "testing administrator" role
    When I click "View Profile"
    Then I should be on "user"
  Scenario: user administrator role
    Given I am logged in as a user with the "user administrator" role
    When I click "View Profile"
    Then I should be on "user"
  Scenario: webmaster role
    Given I am logged in as a user with the "webmaster" role
    When I click "View Profile"
    Then I should be on "user"

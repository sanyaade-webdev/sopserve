Feature: Sopcast Stream Management

As a user I want to be able to manage a number of different sopcast streams

  Scenario: Listing running streams with no streams started
    Given that there are no streams running
    When I go to the stream listing page
    Then I should see "No running streams"

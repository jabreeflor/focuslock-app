# FocusLock — BDD Scenarios

> Gherkin test scenarios covering all MVP features.

---

## Feature: Onboarding

```gherkin
Feature: Onboarding
  As a new user
  I want a guided setup flow
  So I can configure FocusLock quickly

  Scenario: Complete onboarding in under 2 minutes
    Given the app is launched for the first time
    When I tap "Get Started"
    Then I see the "How It Works" screen

  Scenario: Grant Screen Time permission
    Given I am on the Permissions screen
    When I tap "Allow Screen Time Access"
    And I approve the system permission dialog
    Then the permission status shows "Granted"
    And the "Continue" button is enabled

  Scenario: Deny Screen Time permission
    Given I am on the Permissions screen
    When I tap "Allow Screen Time Access"
    And I deny the system permission dialog
    Then I see an explanation of why the permission is needed
    And I can retry granting permission

  Scenario: Select apps to block during onboarding
    Given I am on the Setup screen
    When I tap "Choose Apps to Block"
    Then the FamilyControls app picker is presented
    When I select 3 apps
    Then the selected app count shows "3 apps selected"

  Scenario: Choose default difficulty
    Given I am on the Setup screen
    And I have selected at least 1 app to block
    When I select "Medium" difficulty
    And I tap "Create First Schedule"
    Then a default schedule is created with Medium difficulty
    And I am taken to the Home screen
```

---

## Feature: Scheduling

```gherkin
Feature: Scheduling
  As a user
  I want to manage focus schedules
  So blocking happens automatically or on-demand

  Scenario: Create a recurring schedule
    Given I am on the Create Schedule screen
    When I enter "Work Focus" as the schedule name
    And I select Monday through Friday
    And I set start time to "9:00 AM"
    And I set end time to "5:00 PM"
    And I select apps to block
    And I choose "Medium" difficulty
    And I tap "Save"
    Then the schedule "Work Focus" appears in my schedule list
    And it shows "Mon-Fri, 9:00 AM - 5:00 PM"

  Scenario: Create a one-time focus session
    Given I am on the Home screen
    When I tap "Quick Start"
    And I set the duration to 90 minutes
    And I tap "Start Session"
    Then a one-time session begins with a 90-minute countdown
    And my blocked apps are shielded

  Scenario: View all schedules
    Given I have 3 schedules configured
    When I navigate to the Schedules tab
    Then I see all 3 schedules listed
    And active schedules are visually highlighted

  Scenario: Pause a schedule
    Given I have an active schedule "Work Focus"
    When I swipe left on "Work Focus"
    And I tap "Pause"
    Then the schedule status shows "Paused"
    And the blocked apps are no longer shielded for that schedule

  Scenario: Delete a schedule
    Given I have a schedule "Study Time"
    When I swipe left on "Study Time"
    And I tap "Delete"
    And I confirm deletion
    Then "Study Time" is removed from the schedule list

  Scenario: Modify blocked apps outside active session
    Given no focus session is currently active
    When I edit schedule "Work Focus"
    And I add 2 more apps to the block list
    And I tap "Save"
    Then the schedule shows the updated app count
```

---

## Feature: App Locking

```gherkin
Feature: App Locking
  As a user
  I want blocked apps to show a lock screen
  So I can't access them during focus sessions

  Scenario: Open a blocked app during active session
    Given a focus session is active
    And Instagram is in my block list
    When I open Instagram
    Then I see the FocusLock shield screen
    And I see "This app is locked until [end time]"
    And I see a "Start Challenge" button

  Scenario: Lock persists after force-quit
    Given a focus session is active
    And I opened a blocked app and saw the shield
    When I force-quit the blocked app
    And I reopen it
    Then I still see the FocusLock shield screen

  Scenario: Non-blocked apps work normally
    Given a focus session is active
    And Safari is NOT in my block list
    When I open Safari
    Then Safari opens normally without any shield

  Scenario: Apps unlock after session ends
    Given a focus session is active
    And Instagram is blocked
    When the session end time is reached
    Then the shield is removed from Instagram
    And I can open Instagram normally
```

---

## Feature: Unlock Challenges

```gherkin
Feature: Unlock Challenges
  As a user
  I want to solve challenges to unlock apps
  So there is meaningful friction against impulse usage

  Scenario: Solve an Easy math challenge
    Given I am on the shield screen for a blocked app
    And the difficulty is set to "Easy"
    When I tap "Start Challenge"
    Then I see a simple math problem (e.g., "47 + 38 = ?")
    When I enter the correct answer "85"
    And I tap "Submit"
    Then I see "Unlocked for 5 minutes!"
    And the app opens

  Scenario: Solve a Medium word challenge
    Given I am on the shield screen for a blocked app
    And the difficulty is set to "Medium"
    When I tap "Start Challenge"
    Then I see a word problem or pattern challenge
    When I enter the correct answer
    And I tap "Submit"
    Then I see "Unlocked for 10 minutes!"

  Scenario: Solve a Hard logic challenge
    Given I am on the shield screen for a blocked app
    And the difficulty is set to "Hard"
    When I tap "Start Challenge"
    Then I see a logic puzzle or long typing passage
    When I complete the challenge correctly
    Then I see "Unlocked for 15 minutes!"

  Scenario: Submit wrong answer
    Given I am solving a math challenge "47 + 38 = ?"
    When I enter "83"
    And I tap "Submit"
    Then I see "Incorrect, try again"
    And a new challenge is generated

  Scenario: Give up on a challenge
    Given I am on the challenge screen
    When I tap "Give Up"
    Then the attempt is logged as "gave up"
    And I am returned to the shield screen
    And the app remains locked

  Scenario: Temporary unlock expires
    Given I solved a challenge and unlocked an app for 5 minutes
    When 5 minutes have elapsed
    Then the app is blocked again
    And the shield screen reappears on next open

  Scenario: Strict Mode escalates difficulty
    Given Strict Mode is enabled
    And I have already unlocked this app once this session
    When I try to unlock the same app again
    Then the challenge difficulty is one level harder than before
```

---

## Feature: Stats & Dashboard

```gherkin
Feature: Stats & Dashboard
  As a user
  I want to see my focus statistics
  So I can track my discipline over time

  Scenario: View today's focus time
    Given I completed a 2-hour focus session today
    When I navigate to the Stats tab
    Then I see "2h 0m" as today's focus time

  Scenario: View weekly focus time chart
    Given I have focus data for the past 7 days
    When I navigate to the Stats tab
    Then I see a bar chart showing daily focus time

  Scenario: View current streak
    Given I have completed focus sessions for 5 consecutive days
    When I navigate to the Stats tab
    Then I see a streak counter showing "5 🔥"

  Scenario: Streak resets after missed day
    Given I had a 5-day streak
    And I did not complete any session yesterday
    When I navigate to the Stats tab
    Then my streak shows "0"

  Scenario: View unlock attempt breakdown
    Given I made 10 unlock attempts this week
    And 4 were completed and 6 were gave-up
    When I navigate to the Stats tab
    Then I see a pie chart showing 40% completed, 60% gave up

  Scenario: View most blocked apps
    Given I have unlock attempt data
    When I navigate to the Stats tab
    Then I see a ranked list of most-attempted apps

  Scenario: Receive weekly summary notification
    Given it is Sunday evening
    And I have focus data for the week
    When the weekly summary triggers
    Then I receive a notification with focus time, streak, and attempts
```

---

## Feature: Settings

```gherkin
Feature: Settings
  As a user
  I want to configure my preferences
  So FocusLock works the way I want

  Scenario: Change default difficulty
    Given I am on the Settings screen
    When I change default difficulty from "Easy" to "Hard"
    And I return to the Home screen
    Then new sessions default to "Hard" difficulty

  Scenario: Set per-app difficulty
    Given I am on the Settings screen
    When I set Instagram difficulty to "Hard"
    And I set Gmail difficulty to "Easy"
    Then Instagram challenges are Hard level
    And Gmail challenges are Easy level

  Scenario: Adjust unlock duration
    Given I am on the Settings screen
    When I set Easy unlock duration to 3 minutes
    Then solving an Easy challenge unlocks the app for 3 minutes

  Scenario: Enable Strict Mode
    Given I am on the Settings screen
    When I toggle Strict Mode on
    Then I see an explanation of escalating difficulty
    And Strict Mode is active for all sessions

  Scenario: Toggle session notifications
    Given I am on the Settings screen
    When I disable "Session Start" notifications
    Then I no longer receive notifications when sessions begin
    But I still receive "Session End" notifications if enabled
```

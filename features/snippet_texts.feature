Feature: Step definition text snippets

  As a user of Cucumber, I want to get sensible text snippets, so that
  I can write my tests more easily.

Scenario: Suggestions for undefined steps with and without arguments

  Given a standard Cucumber project directory structure
  Given the standard clucumber setup
  Given a file named "features/undefined.feature" with:
  """
  Feature: Undefined steps

    Scenario: Three undefined steps
    Given this step is undefined
    When I use a step with "one arg"
    Then the step "with two args" should "suggest two args"
  """
  When I run cucumber -f progress
  Then it should pass with
  """
  UUU

  1 scenario (1 undefined)
  3 steps (3 undefined)
  
  You can implement step definitions for undefined steps with these snippets:
  
  Given /^this step is undefined$/ do
    pending # express the regexp above with the code you wish you had
  end
  (Given* #?{^this step is undefined$} ()
    ;; express the regexp above with the code you wish you had
    (pending))
  
  When /^I use a step with "([^\\"]*)"$/ do |arg1|
    pending # express the regexp above with the code you wish you had
  end
  (When* #?{^I use a step with "([^"]*)"$} (group-0)
    ;; express the regexp above with the code you wish you had
    (pending))
  
  Then /^the step "([^\\"]*)" should "([^\\"]*)"$/ do |arg1, arg2|
    pending # express the regexp above with the code you wish you had
  end
  (Then* #?{^the step "([^"]*)" should "([^"]*)"$} (group-0 group-1)
    ;; express the regexp above with the code you wish you had
    (pending))
  
  
  """

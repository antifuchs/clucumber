Feature: Table diffing
  
  As a user of clucumber, I want to compare tables against each other
  so that I can more easily tell which aspect of my data are causing
  failures.

Scenario: Simple table diff - table given, compared.

  Given a standard Cucumber project directory structure
  Given the standard clucumber setup
  Given a file named "features/table-diffing.feature" with:
  """
  Feature: Table step args

    Scenario: A working table step
    Given I have a step that wants these args:
    | foo |
    | bar |
    | baz |

    Scenario: A failing table step
    Given I have a step that wants these args:
    | bork |
    | bar  |
    | bork |
  """
  Given a file named "features/step_definitions/table-diffing-steps.lisp" with:
  """
  (Given* #?{^I have a step that wants these args:$} (table) 
    (unless (table-equal '(("foo") ("bar") ("baz")) table)
      (fail "Tables are not equal!")))
  """
  When I run "cucumber -f progress"
  Then it should fail with exactly:
  """
  .F

  (::) failed steps (::)
  
  Tables are not equal! (Cucumber::WireSupport::WireException)
  features/table-diffing.feature:10:in `Given I have a step that wants these args:'
  
  Failing Scenarios:
  cucumber features/table-diffing.feature:9 # Scenario: A failing table step
  
  2 scenarios (1 failed, 1 passed)
  2 steps (1 failed, 1 passed)
  
  """

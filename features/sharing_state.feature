Feature: Sharing state between steps

  As a user of clucumber, 
  I want to record state between steps
  So that I can test that state in my features.

Background:
  Given a standard Cucumber project directory structure
  Given the standard clucumber setup
  Given a file named "features/step_definitions/variable_steps.lisp" with:
  """
  (Given* #?{^I have a clucumber variable "([^"]*)" set to "([^"]*)"$} (variable-name value)
    (setf (var (intern variable-name :keyword)) value))

  (Then* #?{^clucumber variable \"([^\"]*)\" should have value \"([^\"]*)\"$} (variable-name value)
    (assert (string= (var (intern variable-name :keyword)) value)))  

  (Then* #?{^clucumber variable \"([^\"]*)\" should be undefined$} (variable-name)
    (assert (eql (nth-value 1 (var (intern variable-name :keyword))) nil)))
  """

Scenario: State resetting between features
  
  Given a file named "features/shared-state.feature" with:
  """
  Feature: Shared state
    
    Scenario: Scenario with variables

    When I have a clucumber variable "a" set to "value-1"
    When I have a clucumber variable "b" set to "value-2"

    Then clucumber variable "a" should have value "value-1"
    And clucumber variable "b" should have value "value-2"

    Scenario: Scenario without variables

    Then clucumber variable "a" should be undefined
    Then clucumber variable "b" should be undefined    
  """
  When I run cucumber -f progress
  Then it should pass with
  """
  ......
  
  2 scenarios (2 passed)
  6 steps (6 passed)

  """

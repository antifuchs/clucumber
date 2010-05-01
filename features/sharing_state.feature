Feature: Sharing state between steps

  As a user of clucumber, 
  I want to record state between steps
  So that I can test that state in my features.

Scenario: State resetting

  Given I have a clucumber variable "a" set to "value-1"
  Given I have a clucumber variable "b" set to "value-2"

  When I reset the variable state

  Then clucumber variable "a" should be undefined
  And clucumber variable "b" should be undefined

Scenario: Set a variable to a value

  Given I have a clucumber variable "a" set to "value-1"
  When I have a clucumber variable "b" set to "value-2"

  Then clucumber variable "a" should have value "value-1"
  And clucumber variable "b" should have value "value-2"

Scenario: Implicit state resetting

  # When the "Set a variable to a value" step has run:
  Then clucumber variable "a" should be undefined
  Then clucumber variable "b" should be undefined

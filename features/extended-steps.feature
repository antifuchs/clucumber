Feature: Extended steps

  As a user of Clucumber, I want to define multi-line steps
  So that I can test large amounts of text or tables.

Scenario: Multi-line strings

  Given a standard Cucumber project directory structure
  Given the standard clucumber setup
  Given a file named "features/multiline.feature" with:
  """
  Feature: Multiline step args

    Scenario: A multiline string
    Given I have a step that takes one arg:
    \"\"\"
    foo
    bar baz
    \"\"\"
  """
  Given a file named "features/step_definitions/multi-line-steps.lisp" with:
  """
  (Given* #?{^I have a step that takes one arg:$} (string) 
    (assert (string= string "foo
bar baz")))
  """


  When I run `cucumber -q -f progress`
  Then it should pass with exactly:
  """
  .

  1 scenario (1 passed)
  1 step (1 passed)


  """

Scenario: Simple Tables

  Given a standard Cucumber project directory structure
  Given the standard clucumber setup
  Given a file named "features/multiline.feature" with:
  """
  Feature: Table step args

    Scenario: A simple table step
    Given I have a step that wants these args:
    | foo |
    | bar |
    | baz |
  """
  Given a file named "features/step_definitions/table-steps.lisp" with:
  """
  (Given* #?{^I have a step that wants these args:$} (table) 
    (assert (equal '(("foo") ("bar") ("baz")) table)))
  """


  When I run `cucumber -f progress`
  Then it should pass with exactly:
  """
  .

  1 scenario (1 passed)
  1 step (1 passed)


  """

Scenario: Tables with an additional argument

  Given a standard Cucumber project directory structure
  Given the standard clucumber setup
  Given a file named "features/multiline.feature" with:
  """
  Feature: Table step args

    Scenario: A table step that matches additional args
    Given I have step 1 that wants these args:
    | foo |
    | bar |
    And I have step 2 that wants these args:
    | wibbly |
    | wobbly |
  """
  Given a file named "features/step_definitions/table-steps.lisp" with:
  """
  (Given* #?{^I have step (\d+) that wants these args:$} (number table) 
    (case (parse-integer number)
      (1 (assert (equal '(("foo") ("bar")) table)))
      (2 (assert (equal '(("wibbly") ("wobbly")) table)))))
  """


  When I run `cucumber -f progress`
  Then it should pass with exactly:
  """
  ..

  1 scenario (1 passed)
  2 steps (2 passed)


  """

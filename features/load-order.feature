Feature: Load order of files

  As a user of Clucumber, I want the files I specify to be loaded in a
  specific order, so that I can rely on definitions in one file to be
  present in the other.

Scenario: Support files are loaded first

  Given I start clucumber in fixtures/load-order/
  When I load the clucumber-specific files
  Then support/a.lisp should be loaded before step_definitions/a.lisp

Scenario: Files are loaded in alphabetical order

  Given I start clucumber in fixtures/load-order/
  When I load the clucumber-specific files

  Then support/a.lisp should be loaded before support/b.lisp
  And support/b.lisp should be loaded before support/c.lisp

  And step_definitions/a.lisp should be loaded before step_definitions/b.lisp
  And step_definitions/b.lisp should be loaded before step_definitions/c.lisp


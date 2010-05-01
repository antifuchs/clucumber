Feature: Load order of files

  As a user of Clucumber, I want the files I specify to be loaded in a
  specific order, so that I can rely on definitions in one file to be
  present in the other.

Scenario: Files are loaded in alphabetical order, support before steps

  Given a standard Cucumber project directory structure
  Given a stub lisp file named "features/support/a.lisp"
  Given a stub lisp file named "features/support/b.lisp"
  Given a stub lisp file named "features/support/c.lisp"
  Given a stub lisp file named "features/step_definitions/a.lisp"
  Given a stub lisp file named "features/step_definitions/b.lisp"
  Given a stub lisp file named "features/step_definitions/c.lisp"

  When I start clucumber on port 42427
  Then files should be loaded in this order:
  | support/a.lisp          |
  | support/b.lisp          |
  | support/c.lisp          |
  | step_definitions/a.lisp |
  | step_definitions/b.lisp |
  | step_definitions/c.lisp |


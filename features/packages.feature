Feature: Packages

  As a user of clucumber, I want to define a package that includes
  clucumber functionality, so that I can refer to that package more
  conveniently from step definitions.

Scenario: Defining a package in support
  
  Given a standard Cucumber project directory structure
  Given a file named "features/support/package.lisp" with:
  """
(define-test-package MY-TEST-PACKAGE (:use :cl))
  """
  Given a stub lisp file named "features/step_definitions/uses-package.lisp"

  When I start clucumber on port 42427
  Then the packages should be
  | MY-TEST-PACKAGE |

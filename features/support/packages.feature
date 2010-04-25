Feature: Packages

  As a user of clucumber, I want to define a package that includes
  clucumber functionality, so that I can refer to that package more
  conveniently from step definitions.

Scenario: Defining a package in support
  
  When I start clucumber in fixtures/packages/
  Then the current package should be default-package

  When I define some-other-package as the test package
  Then the current package should be some-other-package


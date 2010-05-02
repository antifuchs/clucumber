Feature: Test successes and failures

  As a user of clucumber, I want to rely on it reporting the right
  thing when my tests fail or pass, so that I can see problems as soon
  as they are introduced.

Scenario: Succeeding simple scenario

  Given a standard Cucumber project directory structure
  Given the standard clucumber setup
  Given a file named "features/success.feature" with:
  """
  Feature: Test success

  Scenario: Single scenario
  
    Given this step succeeds
  """
  Given a file named "features/step_definitions/success.lisp" with:
  """
  (Given* #?"^this step succeeds$" () t)
  """

  When I run cucumber -f progress features/success.feature
  Then it should pass with
  """
  .

  1 scenario (1 passed)
  1 step (1 passed)

  """

Scenario: Failing simple scenario

  Given a standard Cucumber project directory structure
  Given the standard clucumber setup
  Given a file named "features/fail.feature" with:
  """
  Feature: Test failure

  Scenario: Single scenario
  
      Given this step fails
  """
  Given a file named "features/step_definitions/fail.lisp" with:
  """
  (Given* #?"^this step fails" () 
     (assert (= 1 0)))
  """

  When I run cucumber -f progress features/fail.feature
  Then it should fail with
  """
  F
  
  (::) failed steps (::)
  
  Caught an error (The assertion (= 1 0) failed. from localhost:42427)
  features/fail.feature:5:in `Given this step fails'
  
  Failing Scenarios:
  cucumber features/fail.feature:3 # Scenario: Single scenario
  
  1 scenario (1 failed)
  1 step (1 failed)

  """

Scenario: Pending simple scenario

  Given a standard Cucumber project directory structure
  Given the standard clucumber setup
  Given a file named "features/pend.feature" with:
  """
  Feature: Test pendingness

  Scenario: Single scenario
  
      Given this step fails
  """
  Given a file named "features/step_definitions/pend.lisp" with:
  """
  (Given* #?"^this step is pending" () 
    (pending "optional message"))
  """

  When I run cucumber -f progress features/pend.feature
  Then it should pass with
  """
  U
  
  1 scenario (1 undefined)
  1 step (1 undefined)

  You can implement step definitions for undefined steps with these snippets:

  Given /^this step fails$/ do
    pending # express the regexp above with the code you wish you had
  end
  (Given* #?/^this step fails$/ ()
    (pending))


  """

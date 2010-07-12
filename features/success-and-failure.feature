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

  When I run "cucumber -f progress"
  Then it should pass with exactly:
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
     (fail "Fail!"))
  """

  When I run "cucumber -f progress"
  Then it should fail with exactly:
  """
  F
  
  (::) failed steps (::)
  
  Fail! (Cucumber::WireSupport::WireException)
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
  
      Given this step is pending
  """
  Given a file named "features/step_definitions/pending_steps.lisp" with:
  """
  (Given* #?{^this step is pending$} () 
    (pending "optional message"))
  """

  When I run "cucumber -s"
  Then it should pass with exactly:
  """
  Feature: Test pendingness
  
    Scenario: Single scenario
      Given this step is pending
        optional message (Cucumber::Pending)
        features/pend.feature:5:in `Given this step is pending'

  1 scenario (1 pending)
  1 step (1 pending)
  
  """

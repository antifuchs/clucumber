# Taken from cucumber's step definitions

Given /^a standard Cucumber project directory structure$/ do
  create_dir 'features/support'
  create_dir 'features/step_definitions'
end

## This may be interesting for the aruba project (if we drop the :
Then /^it should (pass|fail) with exactly:$/ do |pass_fail, exact_output|
  strip_duration(combined_output).should == exact_output
  if pass_fail == 'pass'
    Then "the exit status should be 0" 
  else
    Then "the exit status should not be 0"
  end
end
